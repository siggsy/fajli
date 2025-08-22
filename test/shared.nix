{ lib, pkgs, sofgLib, ... }:
{
  path = "var/shared";
  name = "shared";

  crypt = sofgLib.crypts.age {
    inherit pkgs;
    recipients = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBoHde/H041J5+GYqoJvTNlcD6lNulv84g30NO6rUfbm ziga@thorin" ];
    identityFiles = [ "$HOME/.ssh/id_ed25519" ];
  };

  generators = {
    shared-ssh = {
      files = {
        "public" = {
          secret = false;
        };

        "private" = {
          secret = true;
        };
      };

      script =
        let
          ssh-keygen = "${pkgs.openssh}/bin/ssh-keygen";
        in
        ''
          ${sofgLib.inputs.single { prompt = "Test input"; var = "in"; }}
          echo "Single input result: $in"
          ${ssh-keygen} -t ed25519 -C "" -N "" -f key -q
          mv key "$out/private"
          mv key.pub "$out/public"
        '';
    };
  };
}
