{ lib, ... }:
{
  imports = [
    lib.fajli.modules.hostKeys
  ];

  path = "vars";

  allowGitless = false;
  debug = true;
  commitChanges = false;

  hosts = [
    "machine1"
    "machine2"
  ];

  defaultRecipients = [
    (lib.fajli.literal "age1tdzspj2xucz94nyr7wng576lcs2uux02hj0fs7a3n6l33ncuzyyq6cfqym")
  ];

  defaultIdentityFiles = [
    "$FAJLI_PROJ_ROOT/test/age.txt"
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
