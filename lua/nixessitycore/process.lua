local json = require 'cjson'

---@class SpawnOpts
---@field cmd string the executable
---@field args table the executable arguments
---@field inherit_stderr boolean to inherit the parent stderr
---@field inherit_stdout boolean to inherit the parent stdout

---Execute a process
---@param opts SpawnOpts
local function spawn(opts)
  ---@type uv
  local uv = require 'luv'
  local output_data = {}
  local output_error = {}
  local code = nil
  local signal = nil

  ---Spawn a child process
  local stdout
  if opts.inherit_stdout then
    stdout = 1
  else
    stdout = uv.new_pipe()
  end
  local stderr
  if opts.inherit_stderr then
    stderr = 2
  else
    stderr = uv.new_pipe()
  end
  local proc_handle, pid = uv.spawn(
    opts.cmd,
    ---@diagnostic disable-next-line
    { args = opts.args, stdio = { nil, stdout, stderr } },

    ---Process on exit callback
    function(c, s)
      code = c
      signal = s
    end
  )

  ---Process stdout listener
  if not opts.inherit_stdout then
    ---@diagnostic disable-next-line
    uv.read_start(stdout, function(err, data)
      assert(not err, err)
      table.insert(output_data, data)
    end)
  end

  ---Process stderr listener
  if not opts.inherit_stderr then
    ---@diagnostic disable-next-line
    uv.read_start(stderr, function(err, data)
      assert(not err, err)
      table.insert(output_error, data)
    end)
  end

  uv.run()
  return code, signal, output_data, output_error
end

---@class ProcessOpts:SpawnOpts
---@field to_json? boolean The resulting output data is converted to json
---@field to_string? boolean The resulting output data is converted to string

---@class Process
---@field exec fun(opts: ProcessOpts): string|table Execute the executable
local M = {
  ---@param opts ProcessOpts
  ---@return string|table # The executable output data
  exec = function(opts)
    local code, signal, data, err = spawn(opts)
    if opts.to_json then
      return json.decode(table.concat(data))
    elseif opts.to_string then
      local trimmed = string.gsub(table.concat(data), '%s+', '')
      return trimmed
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
