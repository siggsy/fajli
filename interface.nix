{ lib, ... }: 
let
  inherit (lib) mkOption;
  inherit (lib.types) submodule functionTo nullOr listOf attrsOf;
  inherit (lib.types) path bool str lines package anything deferredModule;

  fileModule = submodule ({ name, ... }: {
    options = {
      name = mkOption {
        type = str;
        default = name;
        description = ''
          Name of the file
        '';
      };

      path = mkOption {
        type = path;
        description = ''
          Path to the generated file
        '';
      };

      secret = mkOption {
        type = bool;
        default = true;
        description = ''
          Should the file be encrypted using the provided cryptographer?
          If so, it's value will only be available at runtime.
        '';
      };
    };
  });

  generatorModule = submodule ({ name, ... }: {
    options = {
      name = mkOption {
        type = str;
        default = name;
      };

      files = mkOption {
        type = attrsOf fileModule;
        default = {};
        description = ''
          Files produced by the generator
        '';
      };

      script = mkOption {
        type = lines;
        description = ''
          Script used to generate the variables
        '';
      };
    };
  });
in
{
  options = {
    name = mkOption {
      type = str;
      description = ''
        Name of the batch
      '';
    };

    path = mkOption {
      type = str;
    };

    crypt = mkOption {
      type = package;
      description = ''
        Program that is used to encrypt, and decrypt vars
        when generating or editing them.
        In particular, the program should support two commands:
        - encrypt <in_path> <out_path>
        - decrypt <in_path> <out_path>
      '';
    };

    generators = mkOption {
      type = attrsOf generatorModule;
    };
  };
}
