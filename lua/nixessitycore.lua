local function flake_output(flake_path)
  local process = require 'nixessitycore.process'
  local abs_path = process({ cmd = 'readlink', args = { '-f', flake_path }, to_string = true })
  return process({
    cmd = 'nix',
    args = {
      'eval',
      '--expr',
      'builtins.attrNames (builtins.getFlake "%flake_path%").outputs.packages.${builtins.currentSystem}',
      '--impure',
      '--json',
    },
    to_json = true,
    placeholders = { flake_path = abs_path },
  })
end

return setmetatable({ flake_output = flake_output }, {})
