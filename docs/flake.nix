{
  inputs = {
    fajli = {
      url = "path:../";
    };

    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    };
  };

  outputs = { nixpkgs, fajli, ... }:
  let
    pkgs = nixpkgs.legacyPackages.x86_64-linux;
    lib = pkgs.lib.extend (
      final: prev: {
        fajli = import "${fajli}/lib.nix" {
          inherit pkgs;
          lib = final;
        };
      }
    );
    options = (pkgs.lib.evalModules {
      modules = [
        { _module.check = false; }
        "${fajli}/modules/main" ];
      specialArgs = { inherit pkgs lib; };
    }).options;

    optionsHosts = (pkgs.lib.evalModules {
      modules = [
        { _module.check = false; }
        "${fajli}/modules/hosts"
      ];
      specialArgs = { inherit pkgs lib; };
    }).options;
    docs = pkgs.nixosOptionsDoc { inherit options; };
    docsHosts = pkgs.nixosOptionsDoc { options = optionsHosts; };
  in {
    packages.x86_64-linux.docs = pkgs.runCommandNoCC "docs" {} ''
      mkdir -p $out
      cat ${docs.optionsCommonMark} > $out/main.md
      sed -i -e 's/\/docs\/\.\.\///g' $out/main.md
      sed -i -e 's/\/docs\/\\\.\\\.\///g' $out/main.md
      sed -i -e 's/\/nix\/store\/[^/]*\//..\//g' $out/main.md
      sed -i -e 's/file\:\/\///g' $out/main.md
      sed -i '1,63d' $out/main.md

      cat ${docsHosts.optionsCommonMark} > $out/hosts.md
      sed -i -e 's/\/docs\/\.\.\///g' $out/hosts.md
      sed -i -e 's/\/docs\/\\\.\\\.\///g' $out/hosts.md
      sed -i -e 's/\/nix\/store\/[^/]*\//..\//g' $out/hosts.md
      sed -i -e 's/file\:\/\///g' $out/hosts.md
      sed -i '1,63d' $out/hosts.md
    '';
  };
}
