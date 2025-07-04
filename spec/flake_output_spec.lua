local nc = require 'nixessitycore'

describe('flake_output', function()
  it('should return available packages of a flake in impure mode', function()
    assert.has_no.errors(function()
      local data = nc.flake_packages(
        './spec/flakes/single-flake',
        { is_impure = true, is_relative_path = true }
      )
      assert.are.same({ 'cowsay', 'hello' }, data)
    end)
  end)
end)
