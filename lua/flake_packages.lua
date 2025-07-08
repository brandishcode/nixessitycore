local flake_packages = require 'nixessitycore'.flake_packages

local flake_path = arg[1]

local output = flake_packages(flake_path, nil, {to_string = true})
print(output)
os.exit(0)
