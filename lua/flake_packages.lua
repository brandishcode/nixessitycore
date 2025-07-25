local cli = require 'cliargs'

cli:set_name('flake_packages')

-- default arguments
cli:argument('FLAKE_PATH', 'path to flake; can be absolute or relative path')

-- options
cli:option('--owner=GIT_REPOSITORY_OWNER', 'git repository owner', nil)
cli:option('--repo=GIT_REPOSITORY', 'git repository', nil)
cli:option('--rev=GIT_REPOSITORY_REVISION', 'git repository', nil)
cli:option('-b, --build=PACKAGE', 'package to build from flake outputs.packages', nil)

-- flags
cli:flag('-v, --verbose', 'output debug logs')
cli:flag('--debug', 'output debug logs to file')
cli:flag('-f, --local', 'flake is local')

local args, err = cli:parse(arg)

local level = 'info'
local show_debug = false
if args ~= nil and args['v'] then
  show_debug = args['v']
  level = 'debug'
end

local file_log = false
if args ~= nil and args['debug'] then
  file_log = true
end

local build_package = nil
if args ~= nil and args['b'] then
  build_package = args['b']
end

local appender = require 'bcappender'
appender.setup({ name = 'flake_packages', level = level, is_file_log = file_log })
local log = appender.get_log()

if not args and err then
  log:fatal('%s: %s', cli.name, err)
  os.exit(1)
end

local owner = args['owner']
local repo = args['repo']
local is_local = args['local']

if not is_local and (not owner or not repo) then
  log:fatal('%s: --local flag not set, --owner and --repo should be set', cli.name)
  os.exit(1)
end

local flake_path = args['FLAKE_PATH']
log:debug('argument FLAKE_PATH: %s', flake_path)
log:debug('option owner: %s', owner)
log:debug('option repo: %s', repo)
log:debug('option build: %s', build_package)
log:debug('flag local: %s', is_local)

local flake_packages = require 'nixessitycore'.flake_packages

local output = appender.get_output_log()

local flake_opt = { mode = 'list', debug_mode = 'none' }

if show_debug then
  flake_opt.debug_mode = 'store'
end

if build_package ~= nil then
  flake_opt.mode = 'build'
  flake_opt.pkg = build_package
end

local result, err_result, ret_code = flake_packages(flake_path, flake_opt)
if not show_debug then
  output:info(result)
end
if err_result ~= nil then
  for _, v in ipairs(err_result) do
    log:error(v)
  end
end
log:debug('exit with: %s; result: %s', ret_code, result)
os.exit(ret_code)
