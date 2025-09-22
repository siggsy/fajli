{ lib, fajliConfig, python3Packages, writeText, coreutils, diffutils, bash, age, gitMinimal }: python3Packages.buildPythonApplication {
  pname = "fajli";
  version = "0.0.1";
  src = ./src;
  pyproject = true;
  build-system = with python3Packages; [ setuptools ];
  
  makeWrapperArgs = [
    "--set" "PATH" "${lib.makeBinPath [ bash coreutils diffutils age gitMinimal ]}"
    "--set" "FAJLI_CONFIG" "${writeText "fajli-config" (builtins.toJSON fajliConfig)}"
  ];
}
