{ stdenv, fetchzip }:

stdenv.mkDerivation {
  pname = "ssq";
  version = "7.0";
  src = fetchzip {
    url = "https://analogobsession.com/wp-content/uploads/2023/12/SSQ_7.0.zip";
    hash = "sha256-IRwW/DcDTPNvCMqMkNbc/DJRM8J4/51kKechpsvUwh4=";
    stripRoot = false;
  };

  installPhase = ''
    mkdir -p $out/lib/winvst3
    cp -r SSQ.vst3 $out/lib/winvst3
  '';
}
