require 'appender'.setup('flake_packages test', false, false)

local nc = require 'nixessitycore'
local delete_build_links = require 'test.build_links'.delete_build_links
local create_build_links = require 'test.build_links'.create_build_links

describe('flake_packages', function()
  setup(function()
    delete_build_links()
    create_build_links()
  end)

  teardown(function()
    delete_build_links()
  end)

  describe('list mode', function()
    describe('impure flake', function()
      it('output packages', function()
        local data = nc.flake_packages('./spec/flakes/single-flake')
        assert.are.same({ 'cowsay', 'hello' }, data)
      end)
    end)

    describe('pure flake', function()
      --pointed to personal git repo
      local git_flake = {
        owner = 'brandishcode',
        repo = 'brandishcode-packages',
        system = 'x86_64-linux',
      }
      it('with rev: output packages', function()
        git_flake.rev = 'bdbaba31d5160dbb091454b37e57ae64b35233f4'
        local data = nc.flake_packages(git_flake)
        assert.are.same({ 'default', 'neovim', 'nixessity' }, data)
      end)
      it('without rev: output packages', function()
        local data = nc.flake_packages(git_flake)
        assert.are.same({ 'default', 'neovim', 'nixessity' }, data)
      end)
    end)
  end)

  describe('build mode', function()
    describe('impure flake', function()
      it('output paths', function()
        local data =
          nc.flake_packages('./spec/flakes/single-flake', { mode = 'build', pkg = 'hello' })
        assert.is_truthy(#data > 0)
        assert.is_not_nil(data[1].drvPath)
      end)

      it('with pkg_link: output link', function()
        local data = nc.flake_packages(
          './spec/flakes/single-flake',
          { mode = 'link', pkg = 'hello', pkg_link = './spec/flake_packages/build_links/hello' }
        )
      end)
    end)
  end)
end)
