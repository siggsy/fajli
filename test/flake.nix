{
  description = "SOVG test flake";

  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    };

    sovg = {
      url = "path:../";
    };
  };

  outputs = { self, nixpkgs, sops-nix, sovg, ... }:
  {
    packages = (sovg.configure {
      sequence =
        (map (h: import ./ssh-keys.nix h) [
          "thorin"
          "pippin"
          "gandalf"
          "frodo"
        ])
        ++ [
          ./shared.nix
        ];
    }).packages;
  };
}
