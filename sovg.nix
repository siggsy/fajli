{ batches, pkgs, lib, ... }:
let
  unlinesMap = f: xs: builtins.concatStringsSep "\n" (map f xs);
in pkgs.writeShellApplication {
  name = "sovg";
  runtimeInputs = [
    pkgs.rage
  ];
  text = ''
    echo ",--------------------------------------------"
    echo "| Siggsy's Opinionated File Generator"
    echo "'--------------------------------------------"

    ${unlinesMap (batch: 
    ''
      echo "[ Executing batch ${batch.name} ]"
      ${unlinesMap (gen:
        ''
        #################
        # Generation
        #################

        echo "[ Generator ${gen.name} ]"

        final="${batch.path}/${gen.name}"
        if [ -d "$final" ]; then
          echo "Already exists. Skipping ..."
        else
          mkdir -p "$final"
          tmp=$(mktemp -d)
          out=$(mktemp -d)
          curr=$PWD

          cd "$tmp"

          out="$out" ${pkgs.writeShellScript "gen-${gen.name}" gen.script}

          cd "$curr"
          rm -rf "$tmp"

          ${unlinesMap (f: "mv \"$out/${f}\" \"$final/${f}\"") (builtins.attrNames gen.files)}
          rm -rf "$out"
        fi

        #################
        # Encryption
        #################

        ${unlinesMap (f: 
        ''
          if [ -f "$final/${f}.enc" ]; then
            echo "Re-encrypting existing file"
            ${lib.getExe batch.crypt} decrypt "$final/${f}.enc" "$final/${f}" 
            rm "$final/${f}.enc"
          fi

          ${lib.getExe batch.crypt} encrypt "$final/${f}" "$final/${f}.enc"
          rm "$final/${f}"
        ''
        ) (builtins.attrNames (lib.filterAttrs (n: v: v.secret) gen.files)) }

        ''
      ) (builtins.attrValues batch.generators)}
    ''
    ) batches}
  '';
}
