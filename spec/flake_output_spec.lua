local nc = require 'nixessitycore'

describe('flake_output', function()
  it('should not return error', function()
    assert.has_no.errors(function()
      local data =
        nc.flake_output('./spec/flakes/single-flake')
      assert.are.same({ 'hello' }, data)
    end)
  end)
end)
