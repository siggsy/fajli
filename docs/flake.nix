{
  inputs = {
    fajli = {
      url = "github:siggsy/fajli";
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
    docs = pkgs.nixosOptionsDoc { inherit options; };
  in {
    packages.x86_64-linux.docs = pkgs.runCommandNoCC "docs" {} ''
      cat ${docs.optionsCommonMark} > $out
    '';
  };
}
