{ stdenv, fetchzip }:

stdenv.mkDerivation {
  pname = "loudmax";
  version = "v1.47";

  src = fetchzip {
    url = "https://www.dropbox.com/scl/fi/s6aawowxty7gpj0crvjq3/LoudMax_v1_47_Linux_x86_LADSPA.tar.gz?rlkey=0lyxstuwvi8pwadlp2nouw4ns&st=0wsjtp1f&dl=1";
    hash = "sha256-Pxdq3h4SjNLlwhlW9laTv4U6QWI8XQUdsihsGwc1yi4=";

    stripRoot = false;
  };

  installPhase = ''
    mkdir -p $out/lib/ladspa
    cp -r la_LoudMax64.so $out/lib/ladspa
  '';
}
