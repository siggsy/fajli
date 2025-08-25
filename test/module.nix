{
  lib,
  ...
}:
{
  path = "var";

  folders =
    let
      public = {
        age.enable = false;
      };
      user_encrypted = {
        age = {
          enable = true;
          recipients = [
            "age1s2jwm42qcfaug0euu5fv7d7udka0x2vq7mcpmc5lc9u46t9nwsss2yl6pr"
          ];
          identityFiles = [
            "$HOME/.config/sops/age/keys.txt"
            "$HOME/.ssh/id_ed25519"
          ];
        };
      };
      share_encrypted = {
        age = {
          enable = true;
          recipients = [ 
            "age1s2jwm42qcfaug0euu5fv7d7udka0x2vq7mcpmc5lc9u46t9nwsss2yl6pr"
          ];
          recipientFiles = [
            "var/machine/ssh/public"
          ];
          identityFiles = [
            "$HOME/.config/sops/age/keys.txt"
            "$HOME/.ssh/id_ed25519"
          ];
        };
      };
    in
    {
      "shared/ssh" = {
        files = {
          public =  public;
          private = share_encrypted;
        };

        script = lib.fajli.scripts.ssh-keygen {};
      };

      "machine/ssh" = {
        before = [ "shared/ssh" ];

        files = {
          public = public;
          private = user_encrypted;
        };

        script = lib.fajli.scripts.ssh-keygen {};
      };
    };
}
