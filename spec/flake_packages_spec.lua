local nc = require 'nixessitycore'

describe('flake_packages', function()
  describe('impure flake', function()
    it('should return available packages', function()
      local data = nc.flake_packages('./spec/flakes/single-flake')
      assert.are.same({ 'cowsay', 'hello' }, data)
    end)
  end)

  describe('pure flake', function()
    it('should return available packages of pure flake', function()
      local data = nc.flake_packages({
        owner = 'brandishcode',
        repo = 'brandishcode-packages',
        rev = 'bdbaba31d5160dbb091454b37e57ae64b35233f4', --pointed to personal git repo
        system = 'x86_64-linux',
      })
      assert.are.same({ 'default', 'neovim', 'nixessity' }, data)
    end)
  end)
end)
