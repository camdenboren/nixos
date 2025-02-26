{ lib, buildFirefoxXpiAddon }:

buildFirefoxXpiAddon rec {
  pname = "easy-container-shortcuts";
  version = "1.6.0";
  addonId = "firefox.container-shortcuts@strategery.io";

  url = "https://addons.mozilla.org/firefox/downloads/file/4068015/${pname}-${version}.xpi";
  sha256 = "sha256-B5MwcMObKuihMTyCGwd6QgX/RrYS5THfZbUosMMH9gc=";

  meta = with lib; {
    homepage = "https://github.com/gsomoza/firefox-easy-container-shortcuts";
    description = "Provides nine easy keyboard shortcuts to open new tabs on different containers";
    license = licenses.bsd2;
    platforms = platforms.all;
  };
}
