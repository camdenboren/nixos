{ stdenv, fetchzip }:

stdenv.mkDerivation rec {
  pname = "maudioplugins";
  version = "17.09.02";

  # dropbox url params
  id = "nacw7exmgd61fzr4qbzla";
  rlKey = "44cmzg8b8oir3926n053tb9k7";
  st = "30o9t5r3";

  src = fetchzip {
    url = "www.dropbox.com/scl/fi/${id}/maudioplugins-${version}.tar.gz?rlkey=${rlKey}&st=${st}&dl=1";
    hash = "sha256-dcnJ21cN4xUE35D9WcSnxcqvlPRoW5QAGCdfrPidTEU=";
    stripRoot = false;
  };

  installPhase = ''
    mkdir -p $out/lib/winvst3
    cp -r $src/maudioplugins/*.vst3 $out/lib/winvst3
  '';
}
