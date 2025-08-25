{ name, path, lib, ... }:
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

    path = mkOption {
      type = str;
      readOnly = true;
      default = "${path}/${name}";
    };

    age = {
      enable = mkEnableOption "age";
      recipients = mkOption {
        type = listOf str;
        default = [];
        description = ''
          List of age recipients
        '';
      };
      recipientFiles = mkOption {
        type = listOf str;
        default = [];
        description = ''
          List of age recipient files
        '';
      };
      identityFiles = mkOption {
        type = listOf str;
        default = [];
        description = ''
          List of age identity files
        '';
      };
    };
  };
}
