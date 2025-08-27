{
  config,
  pkgs,
  lib,
  ...
}:
let
  sort =
    l:
    (lib.lists.toposort (a: b: builtins.any (f: lib.hasPrefix f b.name) a.before || builtins.any (f: lib.hasPrefix f a.name) b.after) l).result;
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

    ${lib.optionalString config.debug "set -x"}

    #################
    # Path checks
    #################

    if ! proj_root=$(git rev-parse --show-toplevel 2>/dev/null); then
      ${if config.allowGitless then
          ''
            echo "Not in git repository. All changes to files will be final!"
            echo -n "Continue in $PWD? [y/N] "
            read -r ans
            if [ -z "$ans" ] || [ "$(echo "$ans" | tr '[:upper:]' '[:lower:]')" != "y" ]; then
              echo "Exiting ..."
              exit 0
            fi
            proj_root="$PWD"
          ''
        else
          ''
            echo "Not in git repository! Exiting ..." >&2
            exit 1
          ''
      }
    fi

    fajli_path=$(realpath "$proj_root/${config.path}")
    readonly fajli_path

    if ! fajli_git=$(git rev-parse --show-toplevel 2>/dev/null); then
      ${if config.allowGitless then
          ''
            echo "Not in git repository. All changes to files will be final!"
            echo -n "Continue in $PWD? [y/N] "
            read -r ans
            if [ -z "$ans" ] || [ "$(echo "$ans" | tr '[:upper:]' '[:lower:]')" != "y" ]; then
              echo "Exiting ..."
              exit 0
            fi
            fajli_git="$PWD"
          ''
        else
          ''
            echo "Not in git repository! Exiting ..." >&2
            exit 1
          ''
      }
    else
      # shellcheck disable=SC2050
      if [ "$fajli_git" != "$proj_root" ] && [ "${toString config.allowGitless}" == "0" ]; then
        echo "Configured relative path falls outside project directory" >&2
        exit 1
      fi
    fi

    main_dir=$(mktemp -d)
    trap 'rm -rf "$main_dir"' EXIT

    if [ -d "$fajli_path" ]; then
      cp -r "$fajli_path" "$main_dir/"
    fi

    cd "$main_dir/"

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
    
    echo "Executing transaction"
    rm -rf "$fajli_path"
    mv "$main_dir/$(basename "$(dirname "$fajli_path")")" "$fajli_path"

    # TODO: a more detailed commit message
    if git -C "$fajli_git" rev-parse --show-toplevel &>/dev/null; then
      echo "Commiting changes"
      # shellcheck disable=SC2016
      echo 'git -C "$fajli_git" add "$fajli_path"'
      # shellcheck disable=SC2016
      echo 'git -C "$fajli_git" commit -m "fajli: $(date)"'
    fi

    echo "Done!"
  '';
}
