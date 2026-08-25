{ lib, buildFirefoxXpiAddon }:

buildFirefoxXpiAddon rec {
  pname = "vimium-new-tab-page";
  version = "1.0";
  addonId = "@vimium-new-tab";

  url = "https://addons.mozilla.org/firefox/downloads/file/4612990/${pname}-${version}.xpi";
  sha256 = "sha256-NuaTGE57twd3LenqGDS8vNwzVRrrELM/bwcvhntKMt0=";

  meta = with lib; {
    homepage = "https://github.com/philc/vimium-new-tab";
    description = "A small browser extension which shows a new tab page that Vimium can control";
    license = licenses.mit;
    platforms = platforms.all;
  };
}
