{ stdenv, fetchzip }:

stdenv.mkDerivation {
  pname = "freq-echo";
  version = "1.2.0";
  src = fetchzip {
    url = "https://www.dropbox.com/scl/fi/rv0zzc5l3twkmwf57qgwe/freq-echo.tar.gz?rlkey=897r1sv3mi6a8lzurpdk4a8b5&st=61q744fy&dl=1";
    hash = "sha256-q27jfXyrgcWyymjGbCUnP2p4BO7YQQanXeRxL3Si6aA=";
    stripRoot = false;
  };
  # installer url = "https://valhallaproduction.s3.us-west-2.amazonaws.com/freqecho/ValhallaFreqEchoWin_V1_2_0.zip";

  installPhase = ''
    mkdir -p $out/lib/winvst3
    cp -r $src/freq-echo/ValhallaFreqEcho.vst3 $out/lib/winvst3
  '';
}
