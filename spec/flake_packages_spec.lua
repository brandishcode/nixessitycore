local nc = require 'nixessitycore'

describe('flake_packages', function()
  it('should throw error if used on unlocked flake reference', function()
    local _, err_output = nc.flake_packages('./spec/flakes/single-flake', {
      is_relative_path = true,
      debug_mode = 'store',
    })
    assert.truthy(string.find(
      table.concat(err_output),
      "error: cannot call 'getFlake' on unlocked flake reference" --nix returned error message
    ) > 0)
  end)

  it('should return available packages of a flake in impure mode', function()
    assert.has_no.errors(function()
      local data =
        nc.flake_packages('./spec/flakes/single-flake', { impure = true, is_relative_path = true })
      assert.are.same({ 'cowsay', 'hello' }, data)
    end)
  end)
end)
