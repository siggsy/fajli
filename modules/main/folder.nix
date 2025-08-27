{
  name,
  lib,
  ...
}:
let
  inherit (lib) mkOption;
  inherit (lib.types) submodule listOf attrsOf;
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
      type = attrsOf (submodule ./file.nix);
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
