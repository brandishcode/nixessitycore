local json = require 'cjson'

---@class ExecutableOpts
---@field cmd string the executable
---@field args table the executable arguments

---Execute a process
---@param opts ExecutableOpts
local function exec(opts)
  local uv = require 'luv'
  local output_data = {}
  local output_error = {}
  local code = nil
  local signal = nil

  ---Spawn a child process
  local stdout = uv.new_pipe()
  local stderr = uv.new_pipe()
  local proc_handle, pid = uv.spawn(
    opts.cmd,
    { args = opts.args, stdio = { nil, stdout, stderr } },

    ---Process on exit callback
    function(c, s)
      code = c
      signal = s
    end
  )

  ---Process stdout listener
  uv.read_start(stdout, function(err, data)
    assert(not err, err)
    table.insert(output_data, data)
  end)

  ---Process stderr listener
  uv.read_start(stderr, function(err, data)
    assert(not err, err)
    table.insert(output_error, data)
  end)

  uv.run()
  return output_data, output_error, code, signal
end

---@class Process
---@field exec fun(opts: ProcessOpts): string|table Execute the executable
---
---@class ProcessOpts:ExecutableOpts
---@field json? boolean The resulting output data is json convertable
---
---@type Process
local M = {
  ---@param opts ProcessOpts
  ---@return string|table # The executable output data
  exec = function(opts)
    local data, err, code, signal = exec(opts)
    if opts.json then
      return json.decode(table.concat(data))
    else
      return data
    end
  end,
}

return setmetatable(M, {
  __call = function(t, opts)
    return t.exec(opts)
  end,
})
