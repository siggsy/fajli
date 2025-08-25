{ lib, config, ... }:
let
  inherit (lib) mkOption;
  inherit (lib.types) attrsOf submoduleWith;
  inherit (lib.types) str;
in
{
  options = {
    path = mkOption {
      type = str;
      description = ''
        Path relative to git root
      '';
    };

    folders = mkOption {
      type = attrsOf (submoduleWith {
        modules = [
          ./folder.nix
        ];
        specialArgs = {
          path = config.path;
        };
        shorthandOnlyDefinesConfig = true;
      });
    };
  };
}
