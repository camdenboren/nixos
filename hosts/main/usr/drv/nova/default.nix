{ stdenv, fetchzip }:

stdenv.mkDerivation {
  pname = "nova";
  version = "2.1.6";
  src = fetchzip {
    url = "https://www.tokyodawn.net/labs/Nova/2.1.6/TDR%20Nova%20(no%20installer).zip";
    hash = "sha256-+sEYwHS905RUIPsYU0pYYMNmUdlkFofnv+r6NIRJGm0=";
  };

  installPhase = ''
    mkdir -p $out/lib/winvst3
    cp -r VST3/x64/TDR\ Nova.vst3 $out/lib/winvst3
  '';
}
