{
  pkgs ? import <nixpkgs> { },
}:

let
  lua = pkgs.lua5_4.withPackages (
    ps: with ps; [
      luv
      lua-cjson
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
