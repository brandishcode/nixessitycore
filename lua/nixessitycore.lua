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

---@alias PackageMode
---| 'list' list the available packages
---| 'build' build a package from the flake

---@alias DebugMode
---| 'none'
---| 'show' show the messages
---| 'store' store in table (used for testing to check whether expected error is correct)

---@class FlakeOpts
---@field mode? PackageMode defaults to `list'
---@field pkg? string the package to build if in 'build' mode
---@field debug_mode? DebugMode defaults to 'none'

---@alias System
---| 'x86_64-linux'
---| 'aarch64-darwin'

---@class GitFlake
---@field owner string
---@field repo string
---@field rev? string
---@field system System

---@param flake_path string|GitFlake
---@param opts? FlakeOpts
---@return string[]|nil # the available packages
---@return string[]|nil # the debug output
local function flake_packages(flake_path, opts)
  local path = flake_path
  local system = '${builtins.currentSystem}'
  local output = {}
  local process = require 'nixessitycore.process'

  local impure = true
  local debug_mode = 'none'

  if opts ~= nil then
    debug_mode = opts.debug_mode
  end

  if type(path) == 'string' then
    path = abs_path(path)
  else
    if path.rev == nil or path.rev == '' then
      system = path.system
      path = string.format('github:%s/%s', path.owner, path.repo)
    else
      system = path.system
      path = string.format('github:%s/%s?rev=%s', path.owner, path.repo, path.rev)
      impure = false
    end
  end

  local args = {
    'eval',
    '--json',
    '--expr',
  }

  if opts ~= nil and opts.mode == 'build' then
  else
    table.insert(
      args,
      string.format('builtins.attrNames (builtins.getFlake "%s").outputs.packages.%s', path, system)
    )
  end

  if impure then
    table.insert(args, '--impure')
  end

  local ret_code = 1

  local listeners = {
    on_stdout = function(_, data)
      table.insert(output, data)
    end,
    on_exit = function(code)
      ret_code = code
    end,
  }

  local err_output = nil

  if debug_mode == 'show' then
    listeners.on_stderr = 'parent'
  elseif debug_mode == 'store' then
    err_output = {}
    listeners.on_stderr = function(_, data)
      table.insert(err_output, data)
    end
  end

  process({
    cmd = 'nix',
    args = args,
    listeners = listeners,
  })

  if ret_code ~= 0 then
    if debug_mode == 'store' then
      return nil, err_output
    else
      error('flake_packages: failed')
    end
  else
    return json.decode(table.concat(output)), err_output
  end
end

return setmetatable({ flake_packages = flake_packages }, {})
