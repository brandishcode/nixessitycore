local abs_path = require 'utils'.abs_path

local function delete_build_links()
  local path = abs_path('./spec/flake_packages')
  local process = require 'nixessitycore.process'
  ---@type SpawnOpts
  local opts = {
    cmd = 'rm',
    args = {
      '-rf',
      path,
    },
  }
  process(opts)
end

local function create_build_links()
  local path = abs_path('./spec/flake_packages')
  local process = require 'nixessitycore.process'
  ---@type SpawnOpts
  local opts = {
    cmd = 'mkdir',
    args = {
      '-p',
      path,
    },
  }
  process(opts)
end

return setmetatable(
  { create_build_links = create_build_links, delete_build_links = delete_build_links },
  {}
)
