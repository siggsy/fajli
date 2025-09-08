{
  description = "Fajli - a file generator for the nix world";

  outputs =
    { nixpkgs, ... }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      eachSystem =
        f:
        builtins.listToAttrs (
          builtins.map (system: {
            name = system;
            value = f {
              pkgs = nixpkgs.legacyPackages.${system};
              inherit system;
            };
          }) systems
        );
    in
    {
      configure =
        { modules, specialArgs ? {}, ... }:
        {
          packages = eachSystem (
            { pkgs, ... }:
            let
              lib = pkgs.lib.extend(final: prev: { fajli = import ./lib.nix { inherit pkgs; lib = final; }; });
            in
            {
              fajli = pkgs.callPackage ./pkgs/fajli {
                fajliConfig =
                  (lib.evalModules {
                    modules = [ ./modules/main ] ++ modules;
                    specialArgs = specialArgs // {
                      inherit pkgs lib;
                    };
                  }).config;
              };
            }
          );
        };
    };
}
