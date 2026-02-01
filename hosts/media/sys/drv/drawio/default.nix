{
  stdenv,
  fetchFromGitHub,
  ant,
  jdk21,
  unzip,
}:

stdenv.mkDerivation rec {
  pname = "drawio";
  version = "29.3.6";
  src = fetchFromGitHub {
    owner = "jgraph";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-C3d8G+FZYEpaI51xRO29qHwEGeHO7Si4C0mcKU1IAeQ=";
  };

  # override hardcoded env vars which would otw. be patched via `docker-entrypoint.sh`
  patches = [ ./url.patch ];

  nativeBuildInputs = [
    ant
    jdk21
    unzip
  ];

  buildPhase = ''
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
