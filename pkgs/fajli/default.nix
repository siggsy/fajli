{ fajliConfig, python3Packages, writeText }: python3Packages.buildPythonApplication {
  pname = "fajli";
  version = "0.0.1";
  src = ./src;
  pyproject = true;
  build-system = with python3Packages; [ setuptools ];

  makeWrapperArgs = [
    "--set" "FAJLI_CONFIG" "${writeText "fajli-config" (builtins.toJSON fajliConfig)}"
  ];
}
