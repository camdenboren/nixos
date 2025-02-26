{ stdenv, fetchzip }:

stdenv.mkDerivation {
  pname = "kotelnikov";
  version = "1.6.5";
  src = fetchzip {
    url = "https://www.tokyodawn.net/labs/Kotelnikov/1.6.5/TDR%20Kotelnikov%20(no%20installer).zip";
    hash = "sha256-f05T44uMAvxJVoDyoEUW2P9v7yo2I8HjBEaJYFzgLUQ=";
    stripRoot = false;
  };

  installPhase = ''
    mkdir -p $out/lib/winvst3
    cp -r TDR\ Kotelnikov\ \(no\ installer\)/VST3/x64/TDR\ Kotelnikov.vst3 $out/lib/winvst3
  '';
}
