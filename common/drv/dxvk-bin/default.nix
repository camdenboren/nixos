{
  lib,
  stdenv,
  fetchurl,
}:

stdenv.mkDerivation rec {
  pname = "dxvk-bin";
  version = "3.1";
  src = fetchurl {
    url = "https://github.com/doitsujin/dxvk/releases/download/v${version}/dxvk-${version}.tar.gz";
    hash = "sha256-MPnMMmh0vjRChVgidURpaM+kwGnbMc5W3zEtZkQXkVQ=";
  };

  installPhase = ''
    cp -r . $out
  '';

  meta = {
    description = "Vulkan-based implementation of D3D8, 9, 10 and 11 for Linux / Wine";
    homepage = "https://github.com/doitsujin/dxvk";
    changelog = "https://github.com/doitsujin/dxvk/releases/tag/v${version}";
    license = lib.licenses.zlib;
    platforms = lib.platforms.all;
  };
}
