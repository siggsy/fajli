{
  description = "Fajli - a file generator for the nix world";

  outputs =
    { ... }:
    {
      configure =
        {
          pkgs,
          modules,
          specialArgs ? { },
          ...
        }:
        let
          lib = pkgs.lib.extend (
            final: prev: {
              fajli = import ./lib.nix {
                inherit pkgs;
                lib = final;
              };
            }
          );
        in
        pkgs.callPackage ./pkgs/fajli {
          fajliConfig =
            (lib.evalModules {
              modules = [ ./modules/main ] ++ modules;
              specialArgs = specialArgs // {
                inherit pkgs lib;
              };
            }).config;
        };
      
      fajliModules.hosts = ./modules/hosts;
    };
}
