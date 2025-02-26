{ stdenv, fetchzip }:

stdenv.mkDerivation {
  pname = "freq-echo";
  version = "1.2.0";
  src = fetchzip {
    url = "http://0.0.0.0:8000/freq-echo.zip"; # served on local network
    hash = "sha256-q27jfXyrgcWyymjGbCUnP2p4BO7YQQanXeRxL3Si6aA=";
    stripRoot = false;
  };
  # installer url = "https://valhallaproduction.s3.us-west-2.amazonaws.com/freqecho/ValhallaFreqEchoWin_V1_2_0.zip";

  installPhase = ''
    mkdir -p $out/lib/winvst3
    cp -r $src/freq-echo/ValhallaFreqEcho.vst3 $out/lib/winvst3
  '';
}
