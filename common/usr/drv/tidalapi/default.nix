{ pkgs }:

pkgs.python313Packages.buildPythonPackage rec {
  pname = "tidalapi";
  version = "0.8.8";
  pyproject = true;

  src = pkgs.fetchFromGitHub {
    owner = "EbbLabs";
    repo = "python-tidal";
    tag = "v${version}";
    hash = "sha256-+O+U8QZhaOdUgPONv1tb5ctiK8NmD2NJK0hokmNtUZM=";
  };

  build-system = with pkgs.python313Packages; [
    poetry-core
  ];

  dependencies = with pkgs.python313Packages; [
    requests
    python-dateutil
    mpegdash
    isodate
    ratelimit
    typing-extensions
    pyaes
  ];

  doCheck = false; # tests require internet access

  pythonImportsCheck = [
    "tidalapi"
  ];
}
