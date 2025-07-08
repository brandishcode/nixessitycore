rockspec_format = "3.0"
package = "nixessitycore"
version = "1.1.0-0"
source = {
   url = "git://github.com/brandishcode/nixessitycore.git",
   tag = "v1.1.0-0"
}
description = {
   summary = "Pure lua wrappers for nix commands.",
   detailed = "Pure lua wrappers for nix commands.",
   homepage = "https://github.com/brandishcode/nixessitycore",
   license = "MIT"
}
dependencies = {
  "luv >= 1.51.0-1",
  "lua-cjson >= 2.1.0",
  "lua_cliargs >= 3.0.2",
  "lualogging >= 1.8.2",
  "ansicolors >= 1.0.2-3"
}
build = {
   type = "builtin",
   modules = {
      nixessitycore = "lua/nixessitycore.lua",
      ["nixessitycore.process"] = "lua/nixessitycore/process.lua",
      ["nixessitycore.utils"] = "lua/utils.lua"
   },
   install = {
     bin = {
       flake_packages = "lua/flake_packages.lua"
     }
   }
}
test = {
  type = "command",
  command = "busted"
}
test_dependencies = {
  "busted"
}
