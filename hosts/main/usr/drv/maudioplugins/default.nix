{ stdenv, fetchzip }:

stdenv.mkDerivation rec {
  pname = "maudioplugins";
  version = "17.08.01";
  src = fetchzip {
    url = "www.dropbox.com/scl/fi/xbiw2jd86gcc4q3sv1z4x/maudioplugins-${version}.tar.gz?rlkey=6fbfbnh9tn1jexni29qd3u3i5&st=ukcrz1e9&dl=1";
    hash = "sha256-/N0HhUgCfNEIDf7jJNXQT0EexB/uuAZdAhyaN/ND0+w=";
    stripRoot = false;
  };

  installPhase = ''
    mkdir -p $out/lib/winvst3
    cp -r $src/maudioplugins/*.vst3 $out/lib/winvst3
  '';
}
