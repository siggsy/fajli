{ lib, config, ... }:
let
  inherit (lib) mkOption;
  inherit (lib.types) attrsOf listOf submoduleWith;
  inherit (lib.types) str bool;

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
    hosts = mkOption {
      type = listOf str;
      default = [ ];
    };

    symmetricEncryption = mkOption {
      type = bool;
      default = true;
    };

    defaultIdentityFiles = mkOption {
      type = listOf str;
      default = [ ];
    };

    defaultRecipients = mkOption {
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
      hostRecipient = h: config.folders."host-keys/${h}".files."public".path;
      hostIdentity = h: config.folders."host-keys/${h}".files."private".path;
      recipientFilesOf = f: map hostRecipient f.hosts;
      identityFilesOf = f: map hostIdentity f.hosts;
      hostKeysFolders = builtins.listToAttrs (
        builtins.map (h: {
          name = "host-keys/${h}";
          value = {
            files = {
              "private" = {
                age = {
                  enable = true;
                  recipients = config.defaultRecipients;
                  identityFiles = config.defaultIdentityFiles;
                };
              };
              "public" = {
                age.enable = false;
              };
            };

            script = lib.fajli.scripts.ssh-keygen { };
          };
        }) hosts
      );

      sharedFolders = builtins.listToAttrs (
        builtins.map (d: {
          name = "shared/${d.name}";
          value = lib.mkMerge [
            (removeAttrs d [ "hosts" ])
            {
              after = [ "host-keys" ];
              files = builtins.mapAttrs (
                name: f:
                lib.optionalAttrs (f.age.enable) {
                  age.recipients = config.defaultRecipients;
                  age.recipientFiles = recipientFilesOf d;
                  age.identityFiles = config.defaultIdentityFiles ++ identityFilesOf d;
                }
              ) d.files;
            }
          ];
        }) (builtins.attrValues config.shared)
      );

      perHostFolders = builtins.listToAttrs (
        builtins.concatMap (
          d:
          map (h: {
            name = "per-host/${h}/${d.name}";
            value = lib.mkMerge [
              (removeAttrs d [ "hosts" ])
              {
                after = [ "host-keys" ];
                files = builtins.mapAttrs (
                  name: f:
                  (lib.optionalAttrs (f.age.enable) {
                    age.recipients = config.defaultRecipients;
                    age.recipientFiles = [ (hostRecipient h) ];
                    age.identityFiles = config.defaultIdentityFiles ++ [ (hostIdentity h) ];
                  })
                ) d.files;
              }
            ];
          }) d.hosts
        ) (builtins.attrValues config.perHost)
      );
    in
    {
      folders = hostKeysFolders // sharedFolders // perHostFolders;
    };
}
