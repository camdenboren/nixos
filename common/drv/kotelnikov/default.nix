{ stdenv, fetchzip }:

stdenv.mkDerivation rec {
  pname = "kotelnikov";
  version = "1.6.7";
  src = fetchzip {
    url = "https://www.tokyodawn.net/labs/Kotelnikov/${version}/TDR%20Kotelnikov%20(no%20installer).zip";
    hash = "sha256-CxRYeBe+t5jN1pNLXHy7KUyzdTZ0oy7E+lK02sZyN7s=";
  };

  installPhase = ''
    mkdir -p $out/lib/winvst3
    cp -r VST3/x64/TDR\ Kotelnikov.vst3 $out/lib/winvst3
  '';

  passthru.updateScript = [
    ../updateScriptTDR.sh
    "tdr-kotelnikov"
    "Kotelnikov"
    "kotelnikov/default.nix"
  ];
}
