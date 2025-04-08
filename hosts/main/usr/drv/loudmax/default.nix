{ stdenv, fetchzip }:

stdenv.mkDerivation {
  pname = "loudmax";
  version = "v1.46";

  src = fetchzip {
    url = "https://www.dropbox.com/scl/fi/f4oyldvfs5bc5yzd4dddu/LoudMax_v1_46_Linux_x86_LADSPA.tar.gz?rlkey=ugykl90lzbrq9yl42oryz0b21&st=e5h5aqk6&dl=1";
    hash = "sha256-jwox6f7FBSnjcugrf+gFijsk0N41dJkyKZgVo+WNQWk=";
    stripRoot = false;
  };

  installPhase = ''
    mkdir -p $out/lib/ladspa
    cp -r la_LoudMax64.so $out/lib/ladspa
  '';
}
