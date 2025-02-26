{ stdenv, fetchzip }:

stdenv.mkDerivation {
  pname = "britpressor";
  version = "3.0";
  src = fetchzip {
    url = "https://analogobsession.com/wp-content/uploads/2023/03/Britpressor_3.0.zip";
    hash = "sha256-RG62j4zOjdPWmtpC8QlHmYODCb/t+XrMYajzjsCrF5c=";
    stripRoot = false;
  };

  installPhase = ''
    mkdir -p $out/lib/winvst3
    cp -r Britpressor.vst3 $out/lib/winvst3
  '';
}
