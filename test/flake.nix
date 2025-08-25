{
  description = "test flake";

  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    };

    fajli = {
      url = "path:../";
    };
  };

  outputs = { self, nixpkgs, fajli, ... }:
  let
    fajliDef = fajli.configure {
      modules = [
        ./module.nix
      ];
    };
  in
  {
    packages = fajliDef.packages;
  };
}
