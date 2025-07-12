local cli = require 'cliargs'

cli:set_name('flake_packages')

-- default arguments
cli:argument('FLAKE_PATH', 'path to flake; can be absolute or relative path')

-- options
cli:option('--owner=GIT_REPOSITORY_OWNER', 'git repository owner', nil)
cli:option('--repo=GIT_REPOSITORY', 'git repository', nil)
cli:option('--rev=GIT_REPOSITORY_REVISION', 'git repository', nil)

-- flags
cli:flag('-v, --verbose', 'output debug logs')
cli:flag('--debug', 'output debug logs to file')
cli:flag('-f, --local', 'flake is local')

local args, err = cli:parse(arg)

local show_debug = false
if args ~= nil and args['v'] then
  show_debug = args['v']
end

local file_log = false
if args ~= nil and args['debug'] then
  file_log = true
end

local appender = require 'appender'
appender.setup('flake_packages', show_debug, file_log)
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
log:debug('flag local: %s', is_local)

local flake_packages = require 'nixessitycore'.flake_packages

local output = appender.get_output_log()

local result, _, ret_code = flake_packages(flake_path, nil, { to_string = true })
if not show_debug then
  output:info(result)
end
log:debug('exit with: %s; result: %s', ret_code, result)
os.exit(ret_code)
