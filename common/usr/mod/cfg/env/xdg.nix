{ ... }:

{
  xdg.desktopEntries = {
    freetube = {
      name = "FreeTube";
      exec = "freetube --no-sandbox --disable-gpu %U";
      terminal = false;
      type = "Application";
      icon = "freetube";
      settings = {
        StartupWMClass = "FreeTube";
        X-AppImage-Version = "0.21.3";
      };
      comment = "A private YouTube client";
      mimeType = [ "application/freetube" ];
      categories = [ "Network" ];
    };
  };
}
