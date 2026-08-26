{ stdenv, fetchzip }:

stdenv.mkDerivation {
  pname = "ssd";
  version = "5.5";
  src = fetchzip {
    url = "https://www.dropbox.com/scl/fi/f4y18v2jcq3p3b7s58x0e/ssd.tar.gz?rlkey=igznyvi3dv54srutmb6qtnnsm&st=be25mr0y&dl=1";
    hash = "sha256-3DCtUmHU8e7Emxt1Aix7AIYpq9cFoH5UwiNa0Ay2PJ0=";
    stripRoot = false;
  };

  installPhase = ''
    mkdir -p $out/lib/winvst3
    cp -r $src/ssd/SSDSampler5.vst3 $out/lib/winvst3
  '';
}
