{
  stdenv,
  fetchFromGitHub,
  ant,
  jdk21,
  unzip,
}:

let
  baseURL = "https://draw.home.local";
  preConfigPath = "src/main/webapp/js/PreConfig.js";
in
stdenv.mkDerivation rec {
  pname = "drawio";
  version = "29.5.2";
  src = fetchFromGitHub {
    owner = "jgraph";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-MJze21tMDwx6NKb6alfcMWUY9rsNg8m3idx/X6aYpR0=";
  };

  nativeBuildInputs = [
    ant
    jdk21
    unzip
  ];

  buildPhase = ''
    # enable local share links
    sed -i 's|DRAWIO_BASE_URL = null|DRAWIO_BASE_URL = "${baseURL}"|g' ${preConfigPath}
    sed -i 's|DRAWIO_VIEWER_URL = null|DRAWIO_VIEWER_URL = "${baseURL}/js/viewer.min.js"|g' ${preConfigPath}
    sed -i 's|DRAWIO_LIGHTBOX_URL = null|DRAWIO_LIGHTBOX_URL = "${baseURL}"|g' ${preConfigPath}

    cd etc/build
    ant war
    cd ../../build
    unzip draw.war
    rm draw.war
    cd ..
  '';

  postInstall = ''
    mkdir -p $out/dist
    cp -r build/* $out/dist
  '';
}
