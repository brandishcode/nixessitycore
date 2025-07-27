local cli = require 'cliargs'

cli:set_name('flake_nixos')

-- default arguments
cli:argument('FLAKE_PATH', 'path to flake; can be absolute or relative path')

-- options
cli:option('-b, --build=USERNAME', 'username of nixos configuration to build', nil)
cli:option('-t, --test=USERNAME', 'username of nixos configuration to test', nil)

-- flags
cli:flag('-v, --verbose', 'output debug logs')

local args, err = cli:parse(arg)

if not args and err then
  error(string.format('%s: %s', cli.name, err))
  os.exit(1)
end

local level = 'info'
local show_debug = false
if args ~= nil and args['v'] then
  show_debug = args['v']
  level = 'debug'
end

local appender = require 'bcappender'
appender.setup({ name = 'flake_packages', level = level, is_file_log = false })
local log = appender.get_log()

if args['b'] and args['t'] then
  log:fatal('Should only use either --build or --test, not both')
  os.exit(1)
end

local username = args['b']
local is_test = false
if username == nil and args['t'] then
  is_test = true
  username = args['t']
end

local flake_path = args['FLAKE_PATH']
log:debug('argument FLAKE_PATH: %s', flake_path)
log:debug('option build: %s', args['b'])
log:debug('option test: %s', args['t'])

local flake_nixos = require 'nixessitycore'.flake_nixos

local output = appender.get_output_log()

local flake_opts = { mode = 'list' }

if username ~= nil then
  flake_opts.username = username
  flake_opts.mode = 'build'
  if is_test then
    flake_opts.mode = 'test'
  end
end

if show_debug then
  flake_opts.debug_mode = 'store'
end

log:debug(flake_opts)
local result, err_result, ret_code = flake_nixos(flake_path, flake_opts)
if not show_debug and not is_test then
  output:info(result)
end
if err_result ~= nil then
  for _, v in ipairs(err_result) do
    log:error(v)
  end
end
if is_test then
  log:debug('exit with: %s', ret_code)
else
  log:debug('exit with: %s; result: %s', ret_code, result)
end
os.exit(ret_code)
