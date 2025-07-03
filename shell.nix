{
  pkgs ? import <nixpkgs> { },
}:

let
  lua = pkgs.luajit.withPackages (
    ps: with ps; [
      luv
      lua-cjson
      sqlite
      busted
    ]
  );
in
pkgs.mkShell {
  packages = [ lua ];
  shellHook = ''
    export LUA_PATH="$PATH;./lua/?.lua"
  '';
}
