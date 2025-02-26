{ stdenv, fetchzip }:

stdenv.mkDerivation {
  pname = "loudmax";
  version = "v1.45";
  src = fetchzip {
    url = "https://www.dropbox.com/scl/fi/2s22hrnpdd6w48197gqch/LoudMax_v1_45_Linux_x86_LADSPA.tar.gz?rlkey=h5fvfmx4bdjhiheohx4ogfv2q&dl=1";
    hash = "sha256-B/vji0NN96hq5COSgjHdLiFzaDwOWv9veZ7TeEvIigs=";
    stripRoot = false;
  };

  nativeBuildInputs = [ ];

  installPhase = ''
    mkdir -p $out/lib/ladspa
    cp -r la_LoudMax64.so $out/lib/ladspa
  '';
}
