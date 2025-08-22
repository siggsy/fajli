{
  description = "Siggsy's ideal 'vars' implementation (using sops-nix)";

  outputs = { nixpkgs, ... }: 
  let
    systems = [
      "x86_64-linux"
      "aarch64-linux"
    ];

    eachSystem = f: builtins.listToAttrs (builtins.map (system: {
      name = system;
      value = f {
        pkgs = nixpkgs.legacyPackages.${system};
        inherit system;
      };
    }) systems);
  in {

    nixosModules = {
      default = {
        imports = [
          ./interface.nix
        ];
      };
    };

    configure = { sequence, ... }: {
      packages = eachSystem ({ pkgs, ... }: {
        sovg = import ./sovg.nix {
          inherit pkgs;
          inherit (pkgs) lib;
          batches = map (m: (pkgs.lib.evalModules {
            specialArgs = {
              inherit pkgs;
              sofgLib = import ./lib.nix { inherit pkgs; };
            };
            modules = [
              ./interface.nix
              m
            ];
          }).config) sequence;
        };
      });
    };

  };
}
