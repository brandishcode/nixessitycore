require 'busted.runner'()

describe('flake_output', function()
  it('should not return error', function()
    assert.are.equals(1, 1)
  end)
end)
