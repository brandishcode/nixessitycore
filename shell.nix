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
  packages = [
    lua
    pkgs.luarocks
  ];
  shellHook = ''
    export SHELL=/run/current-system/sw/bin/bash
    export LUA_PATH="$PATH;./lua/?.lua"
  '';
}
