{
  pkgs,
  lib,
  system,
  ...
}:

let
  isLinux = lib.hasSuffix "-linux" system;
  isDarwin = !isLinux;
in
{
  home.packages =
    with pkgs;
    lib.optionals isLinux [
      # Styling and Gnome
      gnomeExtensions.appindicator
      gnomeExtensions.one-window-wonderland
      gnomeExtensions.blur-my-shell
      gnomeExtensions.just-perfection
      adw-gtk3
      dracula-icon-theme
      gnome-tweaks
    ]
    ++ lib.optionals isDarwin [
      autoraise
      betterdisplay
      ice-bar
      rectangle
    ];
}
