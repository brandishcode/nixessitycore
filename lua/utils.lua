require 'nixessitycore.process'

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
  local result = string.gsub(table.concat(output), '%s+', '')
  if result == '' then
    error('abs_path: invalid path')
  end
  return result
end

return setmetatable({ abs_path = abs_path }, {})
