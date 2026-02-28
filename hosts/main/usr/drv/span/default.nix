{ stdenv, fetchzip }:

stdenv.mkDerivation rec {
  pname = "span";
  version = "3.23";
  src = fetchzip {
    url = "https://www.dropbox.com/scl/fi/hesfgdzzccsabvyhuvtc5/span-${version}.tar.gz?rlkey=fbpp9ajg2vd82dmziek5b9rd3&st=r7zjgxo4&dl=1";
    hash = "sha256-91hUz0WDbz7kzT2BbEhfRgxmunNhnzIkWiBsHyVzTwY=";
    stripRoot = false;
  };
  # installer url = "https://www.voxengo.com/files/VoxengoSPAN_323_Win32_64_VST_VST3_AAX_setup.exe";

  installPhase = ''
    mkdir -p $out/lib/winvst3
    cp -r $src/span/SPAN.vst3 $out/lib/winvst3
  '';
}
