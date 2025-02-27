{ stdenv, fetchzip }:

stdenv.mkDerivation {
  pname = "span";
  version = "3.21";
  src = fetchzip {
    url = "https://www.dropbox.com/scl/fi/jz2snfxd4ho8icuhhy074/span.zip?rlkey=ibw5apcr05s36tr0yfhhv4v47&st=yh6xvt3y&dl=1";
    hash = "sha256-8MtChkgRau9IaXEG5Ls4VqKgZbRl1E1A/w44oE9i6oE=";
    stripRoot = false;
  };
  # installer url = "https://www.voxengo.com/files/VoxengoSPAN_321_Win32_64_VST_VST3_AAX_setup.exe";

  installPhase = ''
    mkdir -p $out/lib/winvst3
    cp -r $src/span/SPAN.vst3 $out/lib/winvst3
  '';
}
