{ stdenv, fetchzip }:

stdenv.mkDerivation {
  pname = "ssd";
  version = "5.5";
  src = fetchzip {
    url = "http://0.0.0.0:8000/ssd.zip"; # served on local network
    hash = "sha256-3DCtUmHU8e7Emxt1Aix7AIYpq9cFoH5UwiNa0Ay2PJ0=";
    stripRoot = false;
  };

  installPhase = ''
    mkdir -p $out/lib/winvst3
    cp -r $src/ssd/SSDSampler5.vst3 $out/lib/winvst3
  '';
}
