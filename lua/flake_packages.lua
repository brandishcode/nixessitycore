local cli = require 'cliargs'

cli:set_name('flake_packages')

cli:argument('FLAKE_PATH', 'path to flake; can be absolute or relative path')

-- flags
cli:flag('-v, --verbose', 'output debug logs')
cli:flag('--debug', 'output debug logs to file')

local args, err = cli:parse(arg)

local show_debug = false
if args ~= nil and args['v'] then
  show_debug = args['v']
end

local file_log = false
if args ~= nil and args['debug'] then
  file_log = true
end

local log = require 'log'.default('flake_packages', show_debug, file_log)

if not args and err then
  log:fatal('%s: %s', cli.name, err)
  os.exit(1)
end

local flake_path = args['FLAKE_PATH']
log:debug('argument FLAKE_PATH: %s', flake_path)

local flake_packages = require 'nixessitycore'.flake_packages

local output = require 'log'.output

local result = flake_packages(flake_path, nil, { to_string = true })
output(result)
log:debug('result: %s', result)
os.exit(0)
