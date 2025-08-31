{ lib, ... }:
{
  imports = [
    lib.fajli.modules.hostKeys
  ];

  path = "vars";

  allowGitless = false;
  debug = false;
  commitChanges = false;

  hosts = [
    "machine1"
    "machine2"
  ];

  defaultRecipients = [
    (lib.fajli.literal "age1s2jwm42qcfaug0euu5fv7d7udka0x2vq7mcpmc5lc9u46t9nwsss2yl6pr")
  ];

  defaultIdentityFiles = [
    "$HOME/.config/sops/age/keys.txt"
  ];

  perHost = {
    "folder1" = {
      files = {
        "file1" = {
          age.enable = false;
        };
        "file2" = {
          age.enable = true;
        };
      };

      script = ''
        echo "epik1" >> "$out/file1"
        echo "epik2" >> "$out/file2"
      '';
    };
  };

  shared = {
    "shared1" = {
      files = {
        "file1" = {
          age.enable = false;
        };
        "file2" = {
          age.enable = true;
        };
      };

      script = ''
        echo "epik1" >> "$out/file1"
        echo "epik2" >> "$out/file2"
      '';
    };
  };
}
