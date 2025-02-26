{
  stdenv,
  fetchurl,
  autoPatchelfHook,
  dpkg,
  alsa-lib,
  libX11,
  libXext,
  freetype,
  gnutls,
  curlWithGnuTls,
}:

stdenv.mkDerivation {
  pname = "sitala";
  version = "1.0";
  src = fetchurl {
    url = "https://decomposer.de/sitala/releases/sitala-1.0_amd64.deb";
    hash = "sha256-21BIJm8ZdGyHOxR65PAIjUkHUHSbq/3xS89ArbUc4zM=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    dpkg
  ];

  buildInputs = [
    alsa-lib
    libX11
    libXext
    freetype
    gnutls
    (curlWithGnuTls.overrideAttrs (old: {
      configureFlags = old.configureFlags ++ [
        "--disable-versioned-symbols"
      ];
    }))
  ];

  unpackPhase = ''
    dpkg-deb -x $src .
  '';

  installPhase = ''
    cp -r usr $out 
  '';
}
