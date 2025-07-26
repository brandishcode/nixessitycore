local cli = require 'cliargs'

cli:set_name('flake_nixos')

-- default arguments
cli:argument('FLAKE_PATH', 'path to flake; can be absolute or relative path')

-- options
cli:option('-u, --username=USERNAME', 'username of nixos configuration to build', nil)

local args, err = cli:parse(arg)

local appender = require 'bcappender'
appender.setup({ name = 'flake_packages', level = 'info', is_file_log = false })
local log = appender.get_log()

if not args and err then
  os.exit(1)
end

local username = args['u']

local flake_path = args['FLAKE_PATH']

local flake_nixos = require 'nixessitycore'.flake_nixos

local output = flake_nixos(flake_path, { username = username })

print(output)
