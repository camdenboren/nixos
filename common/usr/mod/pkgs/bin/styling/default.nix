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
      gnomeExtensions.one-window-wonderland
      gnomeExtensions.blur-my-shell
      gnomeExtensions.just-perfection
      gnomeExtensions.focus-changer
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
