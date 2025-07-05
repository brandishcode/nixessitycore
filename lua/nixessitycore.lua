local json = require 'cjson'

local function abs_path(path)
  local output = {}
  local process = require 'nixessitycore.process'
  process({
    cmd = 'readlink',
    args = { '-f', path },
    listeners = {
      on_stdout = function(_, data)
        table.insert(output, data)
      end,
    },
  })
  return string.gsub(table.concat(output), '%s+', '')
end

local function flake_output(flake_path)
  local output = {}
  local process = require 'nixessitycore.process'
  process({
    cmd = 'nix',
    args = {
      'eval',
      '--expr',
      string.format(
        'builtins.attrNames (builtins.getFlake "%s").outputs.packages.${builtins.currentSystem}',
        abs_path(flake_path)
      ),
      '--impure',
      '--json',
    },
    listeners = {
      on_stdout = function(_, data)
        table.insert(output, data)
      end,
    },
  })
  return json.decode(table.concat(output))
end

return setmetatable({ flake_output = flake_output }, {})
