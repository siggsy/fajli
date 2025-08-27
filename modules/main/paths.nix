{ lib, config, ... }: 
let
  inherit (lib) mkOption;
  inherit (lib.types) submodule attrsOf;
  inherit (lib.types) str;

  path = config.path;

  fileExtension = folder: { name, ... }: {
    options = {
      path = mkOption {
        type = str;
        readOnly = true;
        default = "${path}/${folder}/${name}";
      };
    };
  };

  folderExtension = { name, ... }: {
    options = {
      path = mkOption {
        type = str;
        readOnly = true;
        default = "${path}/${name}";
      };

      files = mkOption {
        type = attrsOf (submodule (fileExtension name));
      };
    };
  };
in
{
  options = {
    folders = mkOption {
      type = attrsOf (submodule folderExtension);
    };
  };
}
