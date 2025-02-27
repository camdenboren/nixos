{ stdenv, fetchzip }:

stdenv.mkDerivation {
  pname = "ssd";
  version = "5.5";
  src = fetchzip {
    url = "https://www.dropbox.com/scl/fi/4r7uw63uz8na29fdx09fj/ssd.zip?rlkey=fa599vvzh30rj9felejx0pm7z&st=7qyq8r8i&dl=1";
    hash = "sha256-3DCtUmHU8e7Emxt1Aix7AIYpq9cFoH5UwiNa0Ay2PJ0=";
    stripRoot = false;
  };

  installPhase = ''
    mkdir -p $out/lib/winvst3
    cp -r $src/ssd/SSDSampler5.vst3 $out/lib/winvst3
  '';
}
