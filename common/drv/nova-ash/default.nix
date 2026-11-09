{ lib, buildFirefoxXpiAddon }:

buildFirefoxXpiAddon rec {
  pname = "nova-ash";
  version = "1.1";
  addonId = "nova-ash@mozilla.org";

  url = "https://addons.mozilla.org/firefox/downloads/file/5048390/nova_ash-${version}.xpi";
  sha256 = "sha256-Bp5C630fYocH972+Bds4H4MqwBJfANWpniZzs/fAN8I=";

  meta = with lib; {
    homepage = "https://addons.mozilla.org/en-US/firefox/addon/nova-ash/";
    description = "A cool, quiet gray left behind by dying embers.";
    license = licenses.cc-by-40;
    platforms = platforms.all;
  };
}
