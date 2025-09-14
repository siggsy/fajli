{ name, lib, ... }:
let
  inherit (lib) mkOption mkEnableOption;
  inherit (lib.types) listOf;
  inherit (lib.types) str;
in
{
  options = {
    name = mkOption {
      type = str;
      default = name;
      description = ''
        Name of the file to generate
      '';
    };

    age = {
      enable = mkEnableOption "age";
      symmetric = mkEnableOption "symmetric encryption";
      recipients = mkOption {
        type = listOf lib.fajli.types.key;
        default = [];
        description = ''
          List of recipients to pass to age (using -r or -R flag)
        '';
      };
      identityFiles = mkOption {
        type = listOf str;
        default = [];
        description = ''
          List of paths to identity files
        '';
      };
    };
  };
}
