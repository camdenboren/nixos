{ stdenv, fetchzip }:

stdenv.mkDerivation {
  pname = "abstract-vox";
  version = "1";
  src = fetchzip {
    url = "https://www.dropbox.com/scl/fi/ukxp8icaf876080f1sxk6/Abstract_Vox_64bit.zip?rlkey=4sncl4yyouds8prdxb39wqgov&st=f36awygt&dl=1";
    hash = "sha256-kkLZPWvMna4OUBjjbLodVvNM/lDd8hcsM7VXXKPNex0=";
    stripRoot = false;
  };

  installPhase = ''
    mkdir -p $out/lib/winvst3
    cp -r "$src"/Abstract_Vox_64bit/Abstract\ Vox.dll $out/lib/winvst3
    cp -r "$src"/Abstract_Vox_64bit/Abstract\ Vox.instruments $out/lib/winvst3
  '';
}
