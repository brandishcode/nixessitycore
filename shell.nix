{
  pkgs ? import <nixpkgs> { },
  bc-core,
}:

let
  lua = pkgs.lua5_4.withPackages (
    ps: with ps; [
      luv
      lua-cjson
      busted
      lua_cliargs
    ]
  );
in
pkgs.mkShell {
  packages = [
    lua
    pkgs.luarocks
    bc-core
  ];
  shellHook = ''
    export SHELL=/run/current-system/sw/bin/bash
    export LUA_PATH="$PATH;./lua/?.lua"
  '';
}
