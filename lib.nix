{ pkgs, lib, ... }:
rec {
  modules = {
    hostKeys = ./modules/hostKeys;
  };

  types = {
    key = pkgs.lib.mkOptionType {
      name = "key";
      check = (
        v:
        builtins.isAttrs v
        && builtins.hasAttr "type" v
        && builtins.elem v.type [
          "literal"
          "path"
        ]
      );
    };
  };

  literal = val: {
    type = "literal";
    value = val;
  };

  inputs = {
    single =
      { var, prompt }:
      ''
        echo -n "${prompt}: "
        read -r ${var}
      '';
    multi =
      { var, prompt }:
      ''
        echo -n "${prompt}: "
        ${var}=$(</dev/stdin)
      '';

    yesNo =
      { var, prompt }:
      ''
        ${inputs.single {
          inherit var;
          prompt = "${prompt} [y/N]";
        }}
        ${var}="$(echo "''$${var}" | tr '[:upper:]' '[:lower:]')"
      '';
  };

  scripts = {
    ssh-keygen =
      {
        publicFile ? "public",
        privateFile ? "private",
        type ? "ed25519",
        promptExisting ? false,
        ...
      }:
      ''
        existing=n
        ${
          lib.optionalString promptExisting
          (inputs.yesNo { var = "existing"; prompt = "Use existing key?"; })
        }

        if [ "$existing" == "y" ]; then
          ${inputs.single { var = "public"; prompt = "Public key"; }}
          ${inputs.multi { var = "private"; prompt = "Private key"; }}
          echo "$public" > "$out/${publicFile}"
          echo "$private" > "$out/${privateFile}"
        else
          ${pkgs.openssh}/bin/ssh-keygen -t ${type} -N "" -C "" -q -f key
          mv key.pub "$out/${publicFile}"
          mv key "$out/${privateFile}"
        fi
      '';
  };
}
