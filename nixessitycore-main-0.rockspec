rockspec_format = "3.0"
package = "nixessitycore"
version = "main-0"
source = {
   url = "git://github.com/brandishcode/nixessitycore.git",
   tag = "main"
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
   }
}
test = {
  type = "command",
  command = "busted"
}
test_dependencies = {
  "busted"
}
