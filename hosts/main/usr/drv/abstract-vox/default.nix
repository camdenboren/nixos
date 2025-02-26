{ stdenv, fetchzip }:

stdenv.mkDerivation {
  pname = "abstract-vox";
  version = "1";
  src = fetchzip {
    url = "http://0.0.0.0:8000/Abstract_Vox_64bit.zip"; # served on local network
    hash = "sha256-kkLZPWvMna4OUBjjbLodVvNM/lDd8hcsM7VXXKPNex0=";
    stripRoot = false;
  };

  installPhase = ''
    mkdir -p $out/lib/winvst3
    cp -r "$src"/Abstract_Vox_64bit/Abstract\ Vox.dll $out/lib/winvst3
    cp -r "$src"/Abstract_Vox_64bit/Abstract\ Vox.instruments $out/lib/winvst3
  '';
}
