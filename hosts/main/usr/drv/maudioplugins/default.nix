{ stdenv, fetchzip }:

stdenv.mkDerivation rec {
  pname = "maudioplugins";
  version = "17.08.02";
  src = fetchzip {
    url = "www.dropbox.com/scl/fi/gca9nr38rwg7rokydh3xm/maudioplugins-${version}.tar.gz?rlkey=qozv5cczgn6xbxdhbzdrsd0v1&st=rmkv2zl8&dl=1";
    hash = "sha256-/N0HhUgCfNEIDf7jJNXQT0EexB/uuAZdAhyaN/ND0+w=";
    stripRoot = false;
  };

  installPhase = ''
    mkdir -p $out/lib/winvst3
    cp -r $src/maudioplugins/*.vst3 $out/lib/winvst3
  '';
}
