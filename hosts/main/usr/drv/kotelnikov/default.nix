{ stdenv, fetchzip }:

stdenv.mkDerivation rec {
  pname = "kotelnikov";
  version = "1.6.7";
  src = fetchzip {
    url = "https://www.tokyodawn.net/labs/Kotelnikov/${version}/TDR%20Kotelnikov%20(no%20installer).zip";
    hash = "sha256-sKjy4AZaEDpthKn8ndqK8TjxIuUIpoCYGk+JCZRdYPU=";
    stripRoot = false;
  };

  installPhase = ''
    mkdir -p $out/lib/winvst3
    cp -r TDR\ Kotelnikov\ \(no\ installer\)/VST3/x64/TDR\ Kotelnikov.vst3 $out/lib/winvst3
  '';
}
