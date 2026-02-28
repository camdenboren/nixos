{ stdenv, fetchzip }:

stdenv.mkDerivation rec {
  pname = "maudioplugins";
  version = "17.07.04";
  src = fetchzip {
    url = "https://www.dropbox.com/scl/fi/l0qgcbz59cizs8wqu349v/maudioplugins-${version}.tar.gz?rlkey=72odhz9hp45t1ptimjlf82imp&st=h4ag092x&dl=1";
    hash = "sha256-Tq2yUV/cPsZAF+iZCNhHys08X5R8bFUGEErkglcB4UY=";
    stripRoot = false;
  };
  # installer url = "https://www.meldaproduction.com/downloads/down?name=offline%2Fmaudioplugins_17_07_04.zip&platform=offline&version=17_07_04&mirror=bunnycdn&url=https%3A%2F%2Fmeldaproduction.b-cdn.net%2Fdownload%2Foffline%2Fmaudioplugins_17_07_04.zip&checksum=1a711ccaf476af6ef120148ceafd48cf571baf36";

  installPhase = ''
    mkdir -p $out/lib/winvst3
    cp -r $src/maudioplugins/*.vst3 $out/lib/winvst3
  '';
}
