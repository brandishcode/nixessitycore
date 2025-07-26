rockspec_format = "3.0"
package = "nixessitycore"
version = "1.1.3-0"
source = {
   url = "git://github.com/brandishcode/nixessitycore.git",
   tag = "v1.1.3-0"
}
description = {
   summary = "Pure lua wrappers for nix commands.",
   detailed = "Pure lua wrappers for nix commands.",
   homepage = "https://github.com/brandishcode/nixessitycore",
   license = "MIT"
}
dependencies = {
  "lua_cliargs >= 3.0.2",
  "bc-lua-core"
}
build = {
   type = "builtin",
   modules = {
      nixessitycore = "lua/nixessitycore.lua",
   },
   install = {
     bin = {
       flake_packages = "lua/flake_packages.lua",
       flake_nixos = "lua/flake_nixos.lua"
     }
   }
}
test = {
  type = "command",
  command = "busted"
}
test_dependencies = {
  "busted",
  "lua-cjson >= 2.1.0"
}
