{
  pkgs ? import <nixpkgs> { },
}:

let
  sources = import ./npins;
  bc-lua-core =
    (builtins.getFlake "github:brandishcode/bc-lua-core?rev=${sources.bc-lua-core.revision}")
    .packages.${pkgs.system}.default;
in
pkgs.luaPackages.buildLuarocksPackage {
  pname = "nixessitycore";
  version = "1.1.1-0";

  src = ./.;

  propagatedBuildInputs =
    [ bc-lua-core ]
    ++ (with pkgs.luaPackages; [
      luv
      lua-cjson
      lua_cliargs
    ]);
}
