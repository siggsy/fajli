{ lib, pkgs, ... }:
{
  imports = [
    lib.fajli.modules.hostKeys
  ];

  hosts = [
    "machine1"
    "machine2"
  ];

  perHost = {
    "ssh" = {
      files = {

      };

      script = lib.fajli.scripts.ssh-keygen {

      };
    };
  };

}
