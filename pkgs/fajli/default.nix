{ lib, fajliConfig, python3Packages, writeText, coreutils, diffutils, bash, age, gitMinimal }: python3Packages.buildPythonApplication {
  pname = "fajli";
  version = "0.0.1";
  src = ./src;
  pyproject = true;
  build-system = with python3Packages; [ setuptools ];
  
  makeWrapperArgs = [
    "--set" "FAJLI_CONFIG" "${writeText "fajli-config" (builtins.toJSON fajliConfig)}"
    "--set" "FAJLI_STDENV" "${lib.makeBinPath [ bash coreutils diffutils age gitMinimal ]}"
  ];
}
