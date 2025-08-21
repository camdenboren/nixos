{ ... }:

{
  xdg.desktopEntries = {
    bitwarden = {
      categories = [ "Utility" ];
      comment = "Secure and free password manager for all of your devices";
      exec = "bitwarden --disable-gpu %U";
      icon = "bitwarden";
      mimeType = [ "x-scheme-handler/bitwarden" ];
      name = "Bitwarden";
      type = "Application";
    };

    chromium-browser = {
      actions = {
        new-window = {
          name = "New Window";
          exec = "chromium --disable-gpu";
        };
        new-private-window = {
          name = "New Incognito Window";
          exec = "chromium --disable-gpu --incognito";
        };
      };
      name = "Chromium";
      genericName = "Web Browser";
      icon = "chromium";
      comment = "Access the Internet";
      exec = "chromium --disable-gpu %U";
      startupNotify = true;
      terminal = false;
      type = "Application";
      categories = [
        "Network"
        "WebBrowser"
      ];

      mimeType = [
        "application/pdf"
        "application/rdf+xml"
        "application/rss+xml"
        "application/xhtml+xml"
        "application/xhtml_xml"
        "application/xml"
        "image/gif"
        "image/jpeg"
        "image/png"
        "image/webp"
        "text/html"
        "text/xml"
        "x-scheme-handler/http"
        "x-scheme-handler/https"
        "x-scheme-handler/webcal"
        "x-scheme-handler/mailto"
        "x-scheme-handler/about"
        "x-scheme-handler/unknown"
      ];
    };

    freetube = {
      name = "FreeTube";
      exec = "freetube --no-sandbox --disable-gpu %U";
      terminal = false;
      type = "Application";
      icon = "freetube";
      settings = {
        StartupWMClass = "FreeTube";
        X-AppImage-Version = "0.23.7";
      };
      comment = "A private YouTube client";
      mimeType = [ "application/freetube" ];
      categories = [ "Network" ];
    };
  };
}
