{ stdenv, fetchzip }:

stdenv.mkDerivation {
  pname = "freq-echo";
  version = "1.2.0";
  src = fetchzip {
    url = "https://www.dropbox.com/scl/fi/v8k518fuvo4w7gqljoml3/freq-echo.zip?rlkey=9etgwdpn6n350hihyg2c6m1ec&st=j9whoyh2&dl=1";
    hash = "sha256-q27jfXyrgcWyymjGbCUnP2p4BO7YQQanXeRxL3Si6aA=";
    stripRoot = false;
  };
  # installer url = "https://valhallaproduction.s3.us-west-2.amazonaws.com/freqecho/ValhallaFreqEchoWin_V1_2_0.zip";

  installPhase = ''
    mkdir -p $out/lib/winvst3
    cp -r $src/freq-echo/ValhallaFreqEcho.vst3 $out/lib/winvst3
  '';
}
