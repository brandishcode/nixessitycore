{
  pkgs ? import <nixpkgs> { },
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
  sources = import ./npins;
  bc-lua-core =
    (builtins.getFlake "github:brandishcode/bc-lua-core?rev=${sources.bc-lua-core.revision}")
    .packages.${pkgs.system}.default;
in
pkgs.mkShell {
  packages = [
    pkgs.npins
    lua
    pkgs.luarocks
    bc-lua-core
  ];
  shellHook = ''
    export SHELL=/run/current-system/sw/bin/bash
    export LUA_PATH="$PATH;./lua/?.lua"
  '';
}
