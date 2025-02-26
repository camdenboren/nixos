{ ... }:

{
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      # Audio
      "audio/flac" = "org.gnome.Lollypop.desktop";
      "audio/wav" = "org.gnome.Lollypop.desktop";
      "audio/mpeg" = "org.gnome.Lollypop.desktop";
      "audio/weba" = "org.gnome.Lollypop.desktop";

      # Browser
      "x-scheme-handler/http" = "librewolf.desktop";
      "text/html" = "librewolf.desktop";
      "application/pdf" = "librewolf.desktop";
      "application/xhtml+xml" = "librewolf.desktop";
      "x-scheme-handler/https" = "librewolf.desktop";

      # Images
      "image/jpeg" = "org.gnome.Loupe.desktop";
      "image/png" = "org.gnome.Loupe.desktop";
      "image/gif" = "org.gnome.Loupe.desktop";
      "image/avif" = "org.gnome.Loupe.desktop";
      "image/heic" = "org.gnome.Loupe.desktop";
      "image/heif" = "org.gnome.Loupe.desktop";
      "image/tiff" = "org.gnome.Loupe.desktop";
      "image/svg+xml" = "org.inkscape.Inkscape.desktop";
      "image/svg+xml-compressed" = "org.inkscape.Inkscape.desktop";
      "image/x-xcf" = "gimp.desktop";
      "image/x-compressed-xcf" = "gimp.desktop";
      "image/x-gimp-gbr" = "gimp.desktop";
      "image/x-gimp-pat" = "gimp.desktop";
      "image/x-gimp-gih" = "gimp.desktop";

      # Video
      "video/x-msvideo" = "vlc.desktop";
      "video/mp4" = "vlc.desktop";
      "video/mpeg" = "vlc.desktop";
      "video/webm" = "vlc.desktop";
      "video/quicktime" = "vlc.desktop";
      "video/x-matroska" = "vlc.desktop";
    };
  };
}
