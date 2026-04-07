{ stdenv, fetchzip }:

stdenv.mkDerivation rec {
  pname = "nova";
  version = "2.2.2";

  src = fetchzip {
    url = "https://www.tokyodawn.net/labs/Nova/${version}/TDR%20Nova%20(no%20installer).zip";
    hash = "sha256-L/QuTyNJ4X7WlpQkI8Bpl0FvTv9eGHibqoPEEM84UZQ=";
  };

  installPhase = ''
    mkdir -p $out/lib/winvst3
    cp -r VST3/x64/TDR\ Nova.vst3 $out/lib/winvst3
  '';
}
