local function flake_output(flake_path)
  local process = require 'nixessitycore.process'
  local abs_path = process({ cmd = 'readlink', args = { '-f', flake_path }, to_string = true })
  return process({
    cmd = 'nix',
    args = {
      'eval',
      '--expr',
      string.format(
        'builtins.attrNames (builtins.getFlake "%s").outputs.packages.${builtins.currentSystem}',
        abs_path
      ),
      '--impure',
      '--json',
    },
    to_json = true,
    inherit_stderr = true,
  })
end

return setmetatable({ flake_output = flake_output }, {})
