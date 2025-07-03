local function flake_output(flake_path)
  local process = require 'nixessitycore.process'
  return process({
    cmd = 'nix',
    args = {
      'eval',
      '--expr',
      'builtins.attrNames (builtins.getFlake "'
        .. flake_path
        .. '").outputs.packages.${builtins.currentSystem}',
      '--impure',
      '--json',
    },
    json = true,
  })
end

return setmetatable({ flake_output = flake_output }, {})
