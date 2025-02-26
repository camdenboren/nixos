{ stdenv, fetchzip }:

stdenv.mkDerivation {
  pname = "audiogridder";
  version = "1.2.0";
  src = fetchzip {
    url = "https://audiogridder.com/github/releases/download/release_1_2_0/AudioGridder_1.2.0-Linux.zip";
    hash = "sha256-ujmKB8V9EguesmQaWoFOiwJzwzi1LMFrZ0Gk4hmjxow=";
    stripRoot = true;
  };

  nativeBuildInputs = [ ];

  installPhase = ''
    mkdir -p $out/lib/vst
    cp -r lib/libAudioGridder.so $out/lib/vst
  '';
}
