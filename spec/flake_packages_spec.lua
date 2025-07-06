local nc = require 'nixessitycore'

describe('flake_packages', function()
  describe('impure flake', function()
    it('output packages', function()
      local data = nc.flake_packages('./spec/flakes/single-flake')
      assert.are.same({ 'cowsay', 'hello' }, data)
    end)
  end)

  describe('pure flake', function()
    local git_flake = {
      owner = 'brandishcode',
      repo = 'brandishcode-packages',
      system = 'x86_64-linux',
    }
    it('with rev: output packages', function()
      git_flake.rev = 'bdbaba31d5160dbb091454b37e57ae64b35233f4' --pointed to personal git repo
      local data = nc.flake_packages(git_flake)
      assert.are.same({ 'default', 'neovim', 'nixessity' }, data)
    end)
    it('without rev: output packages', function()
      local data = nc.flake_packages(git_flake)
      assert.are.same({ 'default', 'neovim', 'nixessity' }, data)
    end)
  end)
end)
