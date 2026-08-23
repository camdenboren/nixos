{ python314Packages, fetchFromGitHub }:

python314Packages.buildPythonApplication rec {
  pname = "kiwix-mcp";
  version = "1.5.1";
  pyproject = true;
  src = fetchFromGitHub {
    repo = pname;
    owner = "OscillateLabsLLC";
    tag = "v${version}";
    hash = "sha256-FPIvZe76FAGAmUe8S+qY9XPke/aFxiVrFcasHpjOC2U=";
  };

  dependencies = with python314Packages; [
    httpx
    mcp
    defusedxml
    beautifulsoup4
    lxml
  ];
  build-system = with python314Packages; [ hatchling ];

  postPatch = ''
    sed -i 's|httpx.Client(timeout=timeout, follow_redirects=True)|httpx.Client(timeout=timeout, follow_redirects=True, verify="/home/camdenboren/etc/nixos/common/sys/dot/acme/home-local.pem")|' kiwix_client/client.py
  '';
}
