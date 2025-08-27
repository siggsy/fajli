{ lib, ... }:
{
  imports = [
    lib.fajli.modules.hostKeys
  ];

  hosts = [
    "machine1"
    "machine2"
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

}
