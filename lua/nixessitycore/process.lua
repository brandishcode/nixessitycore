---@alias ListenerType
---| "parent" # inherits the parent stdout or stderr

---@alias ListenerCallback ListenerType|fun(err: string, data: string)

---@class Listeners
---@field on_stdout? ListenerCallback by default 'parent'
---@field on_stderr? ListenerCallback by default 'parent'
---@field on_exit? fun(err: string, data: string)

---@class SpawnOpts
---@field cmd string the executable
---@field args table the executable arguments
---@field listeners? Listeners

---Execute a process
---@param opts SpawnOpts
---@return boolean
local function spawn(opts)
  ---@type uv
  local uv = require 'luv'
  ---@type ListenerCallback
  local on_stdout
  ---@type ListenerCallback
  local on_stderr
  local on_exit

  if opts.listeners ~= nil then
    on_stdout = opts.listeners.on_stdout
    on_stderr = opts.listeners.on_stderr
    on_exit = opts.listeners.on_exit
  end

  ---Spawn a child process
  local stdout
  if on_stdout == 'parent' then
    stdout = 1
  else
    stdout = uv.new_pipe()
  end
  local stderr
  if on_stderr == 'parent' then
    stderr = 2
  else
    stderr = uv.new_pipe()
  end

  local proc_handle, pid = uv.spawn(
    opts.cmd,
    ---@diagnostic disable-next-line
    { args = opts.args, stdio = { nil, stdout, stderr } },
    ---@diagnostic disable-next-line
    on_exit
  )

  ---Process stdout listener
  if on_stdout ~= nil and on_stdout ~= 'parent' then
    ---@diagnostic disable-next-line
    uv.read_start(stdout, on_stdout)
  end

  ---Process stderr listener
  if on_stderr ~= nil and on_stderr ~= 'parent' then
    ---@diagnostic disable-next-line
    uv.read_start(stderr, on_stderr)
  end

  return uv.run()
end

---@class Process
---@field exec fun(opts: SpawnOpts): string|table Execute the executable
local M = {
  ---@param opts SpawnOpts
  ---@return boolean
  exec = function(opts)
    return spawn(opts)
  end,
}

return setmetatable(M, {
  __call = function(t, opts)
    return t.exec(opts)
  end,
})
