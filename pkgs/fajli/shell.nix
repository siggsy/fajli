{
  pkgs ? import <nixpkgs> { },
}:
pkgs.mkShell {
  buildInputs = with pkgs; [
    (python3.withPackages (
      p: with p; [
        python-lsp-server
        python-lsp-ruff
      ]
    ))
    coreutils
    age
    pkgs.git
  ];

  FAJLI_STDENV = pkgs.lib.makeBinPath [
    pkgs.bash
    pkgs.coreutils
    pkgs.diffutils
    pkgs.age
    pkgs.git
  ];
}
