{
  name,
  lib,
  path,
  config,
  ...
}:
let
  inherit (lib) mkOption;
  inherit (lib.types) submoduleWith listOf attrsOf;
  inherit (lib.types) str lines;
in
{
  options = {
    name = mkOption {
      type = str;
      default = name;
      description = ''
        Folder name (subpath)
      '';
    };

    path = mkOption {
      type = str;
      default = "${path}/${name}";
    };

    before = mkOption {
      type = listOf str;
      default = [ ];
      description = ''
        Causes the folder to be generated before the specified folders.
      '';
    };

    after = mkOption {
      type = listOf str;
      default = [ ];
      description = ''
        Causes the folder to be generated after the specified folders.
      '';
    };

    files = mkOption {
      type = attrsOf (submoduleWith {
        modules = [
          ./file.nix
        ];
        specialArgs = {
          path = config.path;
        };
        shorthandOnlyDefinesConfig = true;
      });
      description = ''
        Files contained in this folder
      '';
    };

    script = mkOption {
      type = lines;
      default = "";
      description = ''
        A script for generating the files.
      '';
    };
  };
}
