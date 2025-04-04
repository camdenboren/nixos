{ stdenv, fetchzip }:

stdenv.mkDerivation {
  pname = "abstract-vox";
  version = "1";
  src = fetchzip {
    url = "https://www.dropbox.com/scl/fi/q8dwuevl0lmtdomwuz06o/Abstract_Vox_64bit.tar.gz?rlkey=6kcaii85yxb65fhf3drdrg02m&st=yby23907&dl=1";
    hash = "sha256-kkLZPWvMna4OUBjjbLodVvNM/lDd8hcsM7VXXKPNex0=";
    stripRoot = false;
  };

  installPhase = ''
    mkdir -p $out/lib/winvst3
    cp -r "$src"/Abstract_Vox_64bit/Abstract\ Vox.dll $out/lib/winvst3
    cp -r "$src"/Abstract_Vox_64bit/Abstract\ Vox.instruments $out/lib/winvst3
  '';
}
