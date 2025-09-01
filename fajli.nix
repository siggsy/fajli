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
    let
      part = builtins.partition (r: r.type == "literal") file.age.recipients;
      literals = part.right;
      paths = part.wrong;
    in
    builtins.concatStringsSep " " (
      map (l: genArg "r" l.value) literals ++ map (p: genArg "R" p.value) paths
    );
  identitiesOf = file: builtins.concatStringsSep " " (map (genArg "i") file.age.identityFiles);
  encrypedFiles = folder: builtins.attrValues (lib.filterAttrs (n: v: v.age.enable) folder.files);
in
pkgs.writeShellApplication {
  name = "falji";
  runtimeInputs = [
    pkgs.age
    pkgs.git
  ];
  text = ''
    # set -x

    REKEY=
    OVERRIDE_IDENTITY=

    while [ $# -gt 0 ]; do
      case $1 in
        -r|--rekey)
          REKEY=true
          shift
          ;;
        -i|--identity)
          OVERRIDE_IDENTITY=$2
          shift
          shift
          ;;
        *)
          echo "usage: fajli [opts]"
          echo ""
          echo "opts:"
          echo "  -r --rekey      rekey encrypted files"
          echo "  -i --identity   override identity when decrypting"
          echo ""
          exit 1
          ;;
      esac
    done

    echo ",--------------------------------------------"
    echo "| Fajli - nix file generator"
    echo "'--------------------------------------------"

    #################
    # Path checks
    #################

    if ! FAJLI_PROJ_ROOT=$(git rev-parse --show-toplevel 2>/dev/null); then
      ${if config.allowGitless then
          ''
            echo "Not in git repository. All changes to files will be final!"
            echo -n "Continue in $PWD? [y/N] "
            read -r ans
            if [ -z "$ans" ] || [ "$(echo "$ans" | tr '[:upper:]' '[:lower:]')" != "y" ]; then
              echo "Exiting ..."
              exit 0
            fi
            FAJLI_PROJ_ROOT="$PWD"
          ''
        else
          ''
            echo "Not in git repository! Exiting ..." >&2
            exit 1
          ''
      }
    fi

    FAJLI_PATH=$(realpath "$FAJLI_PROJ_ROOT/${config.path}")
    readonly FAJLI_PATH

    if ! fajli_git=$(git -C "$(dirname FAJLI_PATH)" rev-parse --show-toplevel 2>/dev/null); then
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
      if [ "$fajli_git" != "$FAJLI_PROJ_ROOT" ] && [ "${toString config.allowGitless}" == "0" ]; then
        echo "Configured relative path falls outside project directory" >&2
        exit 1
      fi
    fi

    main_dir=$(mktemp -d)
    trap 'rm -rf "$main_dir"' EXIT

    if [ -d "$FAJLI_PATH" ]; then
      cp -a "$FAJLI_PATH/." "$main_dir/"
    fi

    cd "$main_dir/"

    ${unlinesMap (folder: ''
      #################
      # Generation
      #################
      echo "[ Generating folder ${folder.path} ]"

      final="${folder.path}"
      if [ -d "$final" ]; then
        echo "Already exists. Skipping ..."
      else
        mkdir -p "$final"
        tmp=$(mktemp -d)
        out=$(mktemp -d)
        curr=$PWD

        cd "$tmp"

        out="$out" bash ${lib.optionalString config.debug "-x"} ${pkgs.writeText "gen-${folder.name}" folder.script}

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

        if [ -f "$file_enc" ]; then
          if [ -z "$OVERRIDE_IDENTITY" ]; then
            age --decrypt ${identitiesOf f} -o "$file_org" "$file_enc"
          else
            age --decrypt -i "$OVERRIDE_IDENTITY" -o "$file_org" "$file_enc"
          fi
        fi

        if ! [ -f "$file_enc" ] || [ -n "$REKEY" ]; then
          if [ -f "$file_enc" ]; then
            echo "Re-encrypting existing file"
          fi
          age --armor --encrypt ${if f.age.symmetric then identitiesOf f else recipientsOf f} -o "$file_enc" "$file_org" 
        fi
      '') (encrypedFiles folder)}
    '') sortedFolders}

    # Cleanup temp unencrypted
    ${unlinesMap (folder: ''
      ${unlinesMap (file: ''
        rm "${folder.path}/${file.name}"
      '') (encrypedFiles folder)}
    '') sortedFolders}
    
    echo "Executing transaction"
    rm -rf "$FAJLI_PATH"
    mv "$main_dir" "$FAJLI_PATH"

    # TODO: a more detailed commit message
    ${lib.optionalString config.commitChanges ''
      if git -C "$fajli_git" rev-parse --show-toplevel &>/dev/null; then
        git -C "$fajli_git" add "$FAJLI_PATH"

        if [ -z "$(git -C "$fajli_git" diff --staged --minimal "$FAJLI_PATH")" ]; then
          echo "No changes were made!"
        else
          echo "Commiting changes"
          git -C "$fajli_git" commit -m "fajli: $(date)"
        fi
      fi
    '' }
    echo "Done!"
  '';
}
