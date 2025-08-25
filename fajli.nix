{
  config,
  pkgs,
  lib,
  ...
}:
let
  sort =
    l:
    (lib.lists.toposort (a: b: builtins.elem b.name a.before || builtins.elem a.name b.after) l).result;
  sortedFolders = sort (builtins.attrValues config.folders);
  unlinesMap = f: xs: builtins.concatStringsSep "\n" (map f xs);
  genArg = flag: arg: "-${flag} \"${arg}\"";
  recipientsOf =
    file:
    builtins.concatStringsSep " " (
      map (genArg "-r") file.age.recipients ++ map (genArg "-R") file.age.recipientFiles
    );
  identitiesOf = file: builtins.concatStringsSep " " (map (genArg "-i") file.age.identityFiles);
in
pkgs.writeShellApplication {
  name = "falji";
  runtimeInputs = [
    pkgs.age
    pkgs.git
  ];
  text = ''
    echo ",--------------------------------------------"
    echo "| Fajli - nix file generator"
    echo "'--------------------------------------------"
    if ! proj_root=$(git rev-parse --show-toplevel 2>/dev/null); then
      echo "Not in git repository! Exiting ..." >&2
      exit 1
    fi
    cd "$proj_root"

    ${unlinesMap (folder: ''
      #################
      # Generation
      #################
      echo "[ Generating folder ${folder.name} ]"

      final="${folder.path}"
      if [ -d "$final" ]; then
        echo "Already exists. Skipping ..."
      else
        mkdir -p "$final"
        tmp=$(mktemp -d)
        out=$(mktemp -d)
        curr=$PWD

        cd "$tmp"

        out="$out" ${pkgs.writeShellScript "gen-${folder.name}" folder.script}

        cd "$curr"
        rm -rf "$tmp"

        ${unlinesMap (f: "mv \"$out/${f}\" \"$final/${f}\"") (builtins.attrNames folder.files)}
        rm -rf "$out"
      fi

      #################
      # Encryption
      #################

      ${unlinesMap (f: ''
        file_org="$final/${f.name}"
        file_enc="$final/${f.name}.age"
        file_rec="$final/.${f.name}.rec"

        tmp_rec=$(mktemp)
        ${lib.optionalString (
          f.age.recipientFiles != [ ]
        ) ''cat ${builtins.concatStringsSep " " (f.age.recipientFiles)} >> "$tmp_rec"''}
        echo "${builtins.concatStringsSep "\n" (f.age.recipients)}" >> "$tmp_rec"

        reencrypt=0
        if ! [ -f "$file_rec" ] || ! diff "$file_rec" "$tmp_rec" &>/dev/null; then
          cp "$tmp_rec" "$file_rec"
          reencrypt=1
        fi
        rm "$tmp_rec"

        if [ -f "$file_enc" ] && [ "$reencrypt" -eq 1 ]; then
          echo "Re-encrypting existing file"
          age --decrypt ${identitiesOf f} -o "$file_org" "$file_enc"
          rm "$file_enc"
        fi

        if [ "$reencrypt" -eq 1 ]; then
          age --armor --encrypt ${recipientsOf f} -o "$file_enc" "$file_org" 
          rm "$file_org"
        fi
      '') (builtins.attrValues (lib.filterAttrs (n: v: v.age.enable) folder.files))}
    '') sortedFolders}
  '';
}
