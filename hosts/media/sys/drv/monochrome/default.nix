{
  stdenv,
  fetchzip,
  ...
}:

stdenv.mkDerivation rec {
  pname = "monochrome";
  version = "2026.04";
  src = fetchzip {
    url = "https://github.com/camdenboren/${pname}/releases/download/${version}/dist-${version}.tar.xz";
    hash = "sha256-QsgwgKJ57hDu/AUGc2jV1DS1uEFSCjS9f0ddGcqEEzI=";
  };

  installPhase = ''
    mkdir -p $out/dist
    cp -r * $out/dist
  '';
}
