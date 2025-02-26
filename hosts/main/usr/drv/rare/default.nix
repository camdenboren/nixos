{ stdenv, fetchzip }:

stdenv.mkDerivation {
  pname = "rare";
  version = "1.0";
  src = fetchzip {
    url = "https://analogobsession.com/wp-content/uploads/2023/10/RB_Rare_1.0.zip";
    hash = "sha256-p4CLxj2jQpWOaGlU1q3hXZz9+5bHXKDZQxCnaxrMDnA=";
    stripRoot = false;
  };

  installPhase = ''
    mkdir -p $out/lib/winvst3
    cp -r Rare.vst3 $out/lib/winvst3
  '';
}
