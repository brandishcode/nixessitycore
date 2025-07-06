local json = require 'cjson'
local flake_packages = require 'nixessitycore'.flake_packages

local flake_path = arg[1]

local output = flake_packages(flake_path)
print(json.encode(output))
