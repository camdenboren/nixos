{ stdenv, fetchzip }:

stdenv.mkDerivation {
  pname = "span";
  version = "3.21";
  src = fetchzip {
    url = "http://0.0.0.0:8000/span.zip"; # served on local network
    hash = "sha256-8MtChkgRau9IaXEG5Ls4VqKgZbRl1E1A/w44oE9i6oE=";
    stripRoot = false;
  };
  # installer url = "https://www.voxengo.com/files/VoxengoSPAN_321_Win32_64_VST_VST3_AAX_setup.exe";

  installPhase = ''
    mkdir -p $out/lib/winvst3
    cp -r $src/span/SPAN.vst3 $out/lib/winvst3
  '';
}
