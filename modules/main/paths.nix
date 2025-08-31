{ lib, ... }: 
let
  inherit (lib) mkOption;
  inherit (lib.types) submodule attrsOf;
  inherit (lib.types) str;

  fileExtension = folder: { name, ... }: {
    options = {
      path = mkOption {
        type = str;
        readOnly = true;
        default = "${folder}/${name}";
      };
    };
  };

  folderExtension = { name, ... }: {
    options = {
      path = mkOption {
        type = str;
        readOnly = true;
        default = "${name}";
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
