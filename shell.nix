{
  pkgs ? import <nixpkgs> { },
}:

let
  bc-lua-core =
    (builtins.getFlake "github:brandishcode/bc-lua-core?rev=${sources.bc-lua-core.revision}")
    .packages.${pkgs.system}.default;
  lua = pkgs.lua.withPackages (
    ps: with ps; [
      luv
      lua-cjson
      busted
      lua_cliargs
    ]
  );
  sources = import ./npins;

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
    export LUA_PATH="$PATH;./lua/?.lua;${bc-lua-core}/share/lua/${pkgs.lua.version}/?.lua"
  '';
}
