require 'nixessitycore.process'

local function assert_file(path)
  local f = io.open(path, 'r')
  if f == nil then
    error(string.format('abs_path: invalid path (make sure the %s exists)', path))
  else
    io.close(f)
  end
end

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

return setmetatable({ abs_path = abs_path, assert_file = assert_file }, {})
