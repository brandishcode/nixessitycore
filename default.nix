{
  pkgs ? import <nixpkgs> { },
}:

pkgs.luaPackages.buildLuarocksPackage {
  pname = "nixessitycore";
  version = "1.0.1-0";

  src = ./.;

  propagatedBuildInputs = with pkgs.luaPackages; [
    luv
    lua-cjson
  ];
}
