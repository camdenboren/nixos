{ stdenv, fetchzip }:

stdenv.mkDerivation rec {
  pname = "span";
  version = "3.24";
  src = fetchzip {
    url = "https://www.dropbox.com/scl/fi/ssytkknumojc0p87zuyce/span-${version}.tar.gz?rlkey=lboa5ig3ubsvlyv18stlnzhby&st=m5i01973&dl=1";
    hash = "sha256-6/LKon/WrgvSOYXFpYE14rBgnP8GMkBLEFwh3jh0XnA=";
    stripRoot = false;
  };
  # installer url = "https://www.voxengo.com/files/VoxengoSPAN_324_Win32_64_VST_VST3_AAX_setup.exe";

  installPhase = ''
    mkdir -p $out/lib/winvst3
    cp -r $src/span/SPAN.vst3 $out/lib/winvst3
  '';
}
