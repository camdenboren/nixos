{ stdenv, fetchzip }:

stdenv.mkDerivation {
  pname = "maudioplugins";
  version = "16.11";
  src = fetchzip {
    url = "http://0.0.0.0:8000/maudioplugins.zip"; # served on local network
    hash = "sha256-+/g/JZeNilc0U0AOenji8cYVloFVL5BHXIrCMQz1rEI=";
    stripRoot = false;
  };
  # installer url = "https://www.meldaproduction.com/downloads/down?name=maudioplugins&platform=win&version=16.11&mirror=bunnycdn&url=https%3A%2F%2Fmeldaproduction.b-cdn.net%2Fdownload%2Fmaudioplugins%2Fmaudioplugins_16_11_setup.exe&checksum=2d8f56f8c0450c020e3ef1c818d9d662f3fc8877";

  installPhase = ''
    mkdir -p $out/lib/winvst3
    cp -r $src/maudioplugins/*.vst3 $out/lib/winvst3
  '';
}
