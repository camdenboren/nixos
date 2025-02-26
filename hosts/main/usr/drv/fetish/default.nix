{ stdenv, fetchzip }:

stdenv.mkDerivation {
  pname = "fetish";
  version = "6.0";
  src = fetchzip {
    url = "https://analogobsession.com/wp-content/uploads/2023/04/FETish_6.0.zip";
    hash = "sha256-pb3EF/cXCW96/AHKuGy7XdzaHD2sal20ZfcpWenOtPc=";
    stripRoot = false;
  };

  installPhase = ''
    mkdir -p $out/lib/winvst3
    cp -r FETish.vst3 $out/lib/winvst3
  '';
}
