{
  lib,
  python314Packages,
  fetchFromGitHub,
  selfSignedCerts ? false,
  certPath ? null,
}:

python314Packages.buildPythonApplication rec {
  pname = "kiwix-mcp";
  version = "1.5.2";
  pyproject = true;
  src = fetchFromGitHub {
    repo = pname;
    owner = "OscillateLabsLLC";
    tag = "v${version}";
    hash = "sha256-WgXZWIGopJKaUeOKpj0Q7Zxj+/DlqC3UhrxR9sOOJNY=";
  };

  dependencies = with python314Packages; [
    httpx
    mcp
    defusedxml
    beautifulsoup4
    lxml
  ];
  build-system = with python314Packages; [ hatchling ];

  postPatch = lib.optionals selfSignedCerts ''
    sed -i 's|httpx.Client(timeout=timeout, follow_redirects=True)|httpx.Client(timeout=timeout, follow_redirects=True, verify="${certPath}")|' kiwix_client/client.py
  '';
}
