{ lib, config, ... }:
let
  inherit (lib) mkOption;
  inherit (lib.types) attrsOf submodule;
  inherit (lib.types) str bool;
in
{
  imports = [
    ./paths.nix
  ];

  options = {
    path = mkOption {
      type = str;
      description = ''
        Path relative to git root
      '';
    };

    allowGitless = mkOption {
      type = bool;
      default = false;
      description = ''
        Wether to allow generating in gitless folders.
      '';
    };

    debug = mkOption {
      type = bool;
      default = false;
      description = ''
        Add set -x to generated script
      '';
    };

    folders = mkOption {
      type = attrsOf (submodule ./folder.nix);
    };
  };
}
