--[[ Data types - start ]]
---@alias PackageMode
---| 'list' list the available packages
---| 'build' build a package from the flake
---| 'link' build a package from the flake with link

---@alias DebugMode
---| 'none'
---| 'show' show the messages
---| 'store' store in table (used for testing to check whether expected error is correct)

---@class FlakeOpts
---@field mode? PackageMode defaults to `list'
---@field pkg? string the package to build if in 'build' mode
---@field pkg_link string the output link of the built package
---@field debug_mode? DebugMode defaults to 'none'

---@alias System
---| 'x86_64-linux'
---| 'aarch64-darwin'

---@class GitFlake
---@field owner string
---@field repo string
---@field rev? string
---@field system System
--[[ Data types - end ]]

local abs_path = require 'utils'.abs_path
local assert_file = require 'utils'.assert_file
local log = require 'bcappender'.get_log()

---@param flake_path string|GitFlake
---@return string # the flake path
---@return string # the system to be used
---@return boolean # whether target flake is impure or not
local function create_flake_attrs(flake_path)
  local path, system, impure
  if type(flake_path) == 'string' then
    path = abs_path(flake_path)
    assert_file(path .. '/flake.nix')
    impure = true
    system = '${builtins.currentSystem}'
  else
    system = flake_path.system
    if flake_path.rev == nil or flake_path.rev == '' then
      path = string.format('github:%s/%s', flake_path.owner, flake_path.repo)
      impure = true
    else
      path = string.format('github:%s/%s?rev=%s', flake_path.owner, flake_path.repo, flake_path.rev)
      impure = false
    end
  end
  log:debug('flake attributes; path: %s, system: %s, impure: %s', path, system, impure)
  return path, system, impure
end

---@param flake_path string|GitFlake
---@param opts? FlakeOpts
---@return string|string[]|nil # the available packages
---@return string[]|nil # the debug output
---@return number # the exit code
local function flake_packages(flake_path, opts)
  local output = {}
  local process = require 'nixessitycore.process'
  local mode
  local pkg
  local pkg_link
  local debug_mode = 'none'

  if opts ~= nil then
    debug_mode = opts.debug_mode
    mode = opts.mode
    pkg = opts.pkg
    pkg_link = opts.pkg_link
  end

  local path, system, impure = create_flake_attrs(flake_path)

  local args

  if mode == 'build' then
    args = {
      'build',
      '--json',
      '--no-link',
      '--expr',
      string.format('(builtins.getFlake "%s").outputs.packages.%s.%s', path, system, pkg),
    }
  elseif mode == 'link' then
    args = {
      'build',
      '--print-out-paths',
      '--expr',
      string.format('(builtins.getFlake "%s").outputs.packages.%s.%s', path, system, pkg),
    }
    if pkg_link ~= nil then
      table.insert(args, '--out-link')
      table.insert(args, pkg_link)
    end
  else
    args = {
      'eval',
      '--json',
      '--expr',
      string.format(
        'builtins.attrNames (builtins.getFlake "%s").outputs.packages.%s',
        path,
        system
      ),
    }
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

  log:debug('cmd: nix %s %s %s %s %s', table.unpack(args))
  process({
    cmd = 'nix',
    args = args,
    listeners = listeners,
  })

  if ret_code ~= 0 then
    if debug_mode == 'store' then
      return nil, err_output, ret_code
    else
      error('flake_packages: failed')
    end
  else
    return table.concat(output), err_output, ret_code
  end
end

return setmetatable({ flake_packages = flake_packages }, {})
