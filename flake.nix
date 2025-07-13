{
  description = "Nixessity core lua scripts";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    bcfmt.url = "github:brandishcode/brandishcode-formatter";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      bcfmt,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        formatter = bcfmt.formatter.${system};
        devShells.default = pkgs.callPackage ./shell.nix { };
        packages.default = pkgs.callPackage ./default.nix { };
      }
    );
}
