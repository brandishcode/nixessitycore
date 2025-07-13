{
  description = "Nixessity core lua scripts";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    bcfmt.url = "github:brandishcode/brandishcode-formatter";
    bcluacore.url = "github:brandishcode/bc-lua-core";
    bcluacore.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      bcfmt,
      bcluacore,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        bc-core = bcluacore.packages.${system}.default;
      in
      {
        formatter = bcfmt.formatter.${system};
        devShells.default = import ./shell.nix { inherit pkgs bc-core; };
        packages.default = import ./. { inherit pkgs bc-core; };
      }
    );
}
