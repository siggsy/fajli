{ pkgs, ... }:
{
  modules = {
    hostKeys = ./modules/hostKeys;
  };

  crypts = {
    age =
      { recipients, identityFiles, ... }:
      pkgs.writeShellApplication {
        name = "age-crypt";
        runtimeInputs = [
          pkgs.age
        ];
        text = ''
          cmd=$1
          in_file=$2
          out_file=$3

          case "$cmd" in
            encrypt) 
              age ${
                builtins.concatStringsSep " " (map (r: "-r \"${r}\"") recipients)
              } -o "$out_file" "$in_file"
              ;;
            decrypt)
              age ${
                builtins.concatStringsSep " " (map (i: "-i \"${i}\"") identityFiles)
              } -o "$out_file" "$in_file"
              ;;
            *)
              echo "Invalid command"
              exit 1
              ;;
          esac
        '';
      };
  };

  inputs = {
    single =
      { var, prompt, ... }:
      ''
        echo -n "${prompt}"
        read -r ${var}
      '';
    mutli =
      { var, prompt, ... }:
      ''
        echo -n "${prompt}"
        $${var}=$(</dev/stdin)
      '';
  };

  scripts = {
    ssh-keygen =
      {
        publicFile ? "public",
        privateFile ? "private",
        type ? "ed25519",
        ...
      }:
      ''
        ${pkgs.openssh}/bin/ssh-keygen -t ${type} -N "" -C "" -q -f key
        mv key.pub "$out/${publicFile}"
        mv key "$out/${privateFile}"
      '';
  };
}
