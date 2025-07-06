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

---@class FlakeOpts
---@field is_impure? boolean whether the flake is impure
---@field is_relative_path? boolean whether the flake path passed is a relative one

---@param flake_path string
---@param opts FlakeOpts
---@return string[] # the available packages
local function flake_packages(flake_path, opts)
  local path = flake_path
  local output = {}
  local process = require 'nixessitycore.process'

  local is_relative_path = false
  local is_impure = false

  if opts ~= nil then
    is_impure = opts.is_impure
    is_relative_path = opts.is_relative_path
  end

  if is_relative_path then
    path = abs_path(path)
  end

  local args = {
    'eval',
    '--expr',
    string.format(
      'builtins.attrNames (builtins.getFlake "%s").outputs.packages.${builtins.currentSystem}',
      path
    ),
    '--json',
  }

  if is_impure then
    table.insert(args, '--impure')
  end

  process({
    cmd = 'nix',
    args = args,
    listeners = {
      on_stdout = function(_, data)
        table.insert(output, data)
      end,
    },
  })
  return json.decode(table.concat(output))
end

return setmetatable({ flake_packages = flake_packages }, {})
