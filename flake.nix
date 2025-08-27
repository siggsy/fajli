{
  description = "Fajli - a file generator for the nix world";

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

    configure = { modules, ... }: {
      packages = eachSystem ({ pkgs, ... }: {
        fajli = import ./fajli.nix {
          inherit pkgs;
          lib = pkgs.lib;
          config = (pkgs.lib.evalModules {
            modules = [ ./modules/main ] ++ modules;
            specialArgs = {
              inherit pkgs;
              lib = pkgs.lib // { fajli = (import ./lib.nix { inherit pkgs; }); };
            };
          }).config;
        };
      });
    };
  };
}
