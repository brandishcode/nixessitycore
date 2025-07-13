{
  pkgs ? import <nixpkgs> { },
  bc-core,
}:

pkgs.luaPackages.buildLuarocksPackage {
  pname = "nixessitycore";
  version = "1.1.0-0";

  src = ./.;

  propagatedBuildInputs = with pkgs.luaPackages; [
    luv
    lua-cjson
    lua_cliargs
    bc-core
  ];
}
