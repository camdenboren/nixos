{ stdenv, fetchzip }:

stdenv.mkDerivation {
  pname = "span";
  version = "3.21";
  src = fetchzip {
    url = "https://www.dropbox.com/scl/fi/cdyxhzcfs02s005497xe0/span.tar.gz?rlkey=e85n6hp1s3pebh6c1pmz5vo9u&st=lclvumjq&dl=1";
    hash = "sha256-8MtChkgRau9IaXEG5Ls4VqKgZbRl1E1A/w44oE9i6oE=";
    stripRoot = false;
  };
  # installer url = "https://www.voxengo.com/files/VoxengoSPAN_321_Win32_64_VST_VST3_AAX_setup.exe";

  installPhase = ''
    mkdir -p $out/lib/winvst3
    cp -r $src/span/SPAN.vst3 $out/lib/winvst3
  '';
}
