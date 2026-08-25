{
  stdenvNoCC,
  fetchurl,
  innoextract,
  unzip,
}:

stdenvNoCC.mkDerivation rec {
  pname = "freq-echo";
  version = "1.2.0";

  src = fetchurl {
    url = "https://valhallaproduction.s3.us-west-2.amazonaws.com/freqecho/ValhallaFreqEchoWin_V${
      builtins.replaceStrings [ "." ] [ "_" ] version
    }.zip";
    hash = "sha256-yEpFXn79iMeRm82ecrolQtAJnouQWk9KNLDZ+yU3IVs=";
  };

  nativeBuildInputs = [
    innoextract
    unzip
  ];

  dontConfigure = true;
  dontBuild = true;

  unpackPhase = ''
    runHook preUnpack
    unzip -q "$src"
    innoextract --extract --silent "ValhallaFreqEchoWin_V${
      builtins.replaceStrings [ "." ] [ "_" ] version
    }.exe"
    runHook postUnpack
  '';

  installPhase = ''
    mkdir -p $out/lib/winvst3
    cp -r 'code$GetVST3Dir/ValhallaFreqEcho.vst3' $out/lib/winvst3
  '';

  passthru.updateScript = ./update.sh;
}
