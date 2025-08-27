{ lib, ... }:
{
  imports = [
    lib.fajli.modules.hostKeys
  ];

  path = "vars";

  allowGitless = true;
  debug = false;

  hosts = [
    "machine1"
    "machine2"
  ];

  defaultRecipients = [
    "age1s2jwm42qcfaug0euu5fv7d7udka0x2vq7mcpmc5lc9u46t9nwsss2yl6pr"
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
