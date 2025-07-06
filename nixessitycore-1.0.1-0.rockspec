rockspec_format = "3.0"
package = "nixessitycore"
version = "1.0.1-0"
source = {
   url = "git://github.com/brandishcode/nixessitycore.git",
   tag = "v1.0.1-alpha"
}
description = {
   summary = "Pure lua wrappers for nix commands.",
   detailed = "Pure lua wrappers for nix commands.",
   homepage = "https://github.com/brandishcode/nixessitycore",
   license = "MIT"
}
dependencies = {
  "luv",
  "lua-cjson"
}
build = {
   type = "builtin",
   modules = {
      nixessitycore = "lua/nixessitycore.lua",
      ["nixessitycore.process"] = "lua/nixessitycore/process.lua",
      utils = "lua/utils.lua"
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
