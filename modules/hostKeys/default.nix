{ lib, config, ... }:
let
  inherit (lib) mkOption submodule submoduleWith;
  inherit (lib.types) attrsOf listOf;
  inherit (lib.types) str bool;

  hostModule =
    { name, ... }:
    {
      options = {
        name = mkOption {
          type = str;
          default = name;
        };
      };
    };

  extendedFolderModule = submoduleWith {
    modules = [
      ../main/folder.nix

      {
        options = {
          hosts = mkOption {
            type = listOf str;
            default = config.hosts;
          };
        };
      }
    ];

    shorthandOnlyDefinesConfig = true;
  };
in
{
  options = {
    hosts = {
      type = attrsOf hostModule;
      default = { };
    };

    symmetricEncryption = mkOption {
      type = bool;
      default = true;
    };

    defaultIdentityFiles = mkOption {
      type = listOf str;
      default = [ ];
    };

    defaultRecepients = mkOption {
      type = listOf str;
      default = [ ];
    };

    perHost = mkOption {
      type = attrsOf extendedFolderModule;
      default = { };
    };

    shared = mkOption {
      type = attrsOf extendedFolderModule;
      default = { };
    };
  };

  config =
    let
      hosts = config.hosts;
      hostRecepient = h: config.folders."host-keys".files."${h}_public".path;
      hostIdentity = h: config.folders."host-keys".files."${h}_private".path;
      recepientFilesOf = f: map hostRecepient f.hosts;
      identityFilesOf = f: map hostIdentity f.hosts;
      hostKeysFolder = {
        "host-keys" = {
          files = builtins.listToAttrs (
            builtins.concatMap (h: [
              {
                name = "${h}_private";
                value = {
                  age = {
                    enable = true;
                    recepients = config.defaultRecepients;
                    identityFiles = config.defaultIdentityFiles;
                  };
                };
              }
              {
                name = "${h}_public";
                value = {
                  age.enable = false;
                };
              }
            ]) hosts
          );

          script = builtins.concatStringsSep "\n" (
            map (
              h:
              lib.fajli.scripts.ssh-keygen {
                private = "${h}_private";
                public = "${h}_public";
              }
            ) hosts
          );
        };
      };

      sharedFolders = builtins.listToAttrs (
        builtins.map (d: {
          name = "shared/${d.name}";
          value = d // {
            name = "shared/${d.name}";
            files = builtins.mapAttrs (
              name: f:
              f
              // (lib.optionalAttrs (f.age.enable) {
                recepients = f.recepients ++ config.defaultRecepients ++ recepientFilesOf;
                identityFiles = f.identityFiles ++ config.defaultIdentityFiles ++ identityFilesOf;
              })
            ) d.files;
          };
        }) (builtins.attrValues config.shared)
      );

      perHostFolders = builtins.listToAttrs (
        builtins.concatMap (
          d:
          map (
            h:
            let
              name = "per-host/${h}/${d.name}";
            in
            {
              name = name;
              value = d // {
                name = name;
                files = builtins.mapAttrs (
                  name: f:
                  f
                  // (lib.optionalAttrs (f.age.enable) {
                    recepients = f.recepients ++ config.defaultRecepients ++ hostRecepient h;
                    identityFiles = f.identityFiles ++ config.defaultIdentityFiles ++ hostIdentity h;
                  })
                ) d.files;
              };
            }
          ) d.hosts
        ) (builtins.attrValues config.perHost)
      );
    in
    {
      folders = hostKeysFolder // sharedFolders // perHostFolders;
    };
}
