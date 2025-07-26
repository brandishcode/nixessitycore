local cli = require 'cliargs'

cli:set_name('flake_nixos')

-- default arguments
cli:argument('FLAKE_PATH', 'path to flake; can be absolute or relative path')

-- options
cli:option('-b, --build=USERNAME', 'username of nixos configuration to build', nil)

-- flags
cli:flag('-v, --verbose', 'output debug logs')

local args, err = cli:parse(arg)

local level = 'info'
local show_debug = false
if args ~= nil and args['v'] then
  show_debug = args['v']
  level = 'debug'
end


local appender = require 'bcappender'
appender.setup({ name = 'flake_packages', level = level, is_file_log = false })
local log = appender.get_log()

if not args and err then
  log:fatal('%s: %s', cli.name, err)
  os.exit(1)
end

local username = args['b']

local flake_path = args['FLAKE_PATH']

local flake_nixos = require 'nixessitycore'.flake_nixos

local output = appender.get_output_log()

local flake_opts = { mode = 'list' }

if username ~= nil then
  flake_opts.username = username
  flake_opts.mode = 'build'
end

local result, err_result, ret_code = flake_nixos(flake_path, flake_opts)
output:info(result)
log:debug('exit with: %s; result: %s', ret_code, result)
