{
  pkgs ? import <nixpkgs> { },
}:

let
  sources = import ./npins;
  bc-lua-core =
    (builtins.getFlake "github:brandishcode/bc-lua-core?rev=${sources.bc-lua-core.revision}")
    .packages.${pkgs.system}.default;
  lua = pkgs.lua.withPackages (
    ps: with ps; [
      lua-cjson
      busted
      lua_cliargs
    ]
  );
  luaPath = "${bc-lua-core}/share/lua/${pkgs.lib.versions.major pkgs.lua.version}.${pkgs.lib.versions.minor pkgs.lua.version}/?.lua";
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
    export LUA_PATH="$PATH;./lua/?.lua;${luaPath}"
  '';
}
