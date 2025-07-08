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
      gnomeExtensions.auto-move-windows
      gnomeExtensions.one-window-wonderland
      gnomeExtensions.blur-my-shell
      gnomeExtensions.just-perfection
      gnomeExtensions.focus-changer
      gnomeExtensions.date-menu-formatter
      adw-gtk3
      dracula-icon-theme
      gnome-tweaks
    ]
    ++ lib.optionals isDarwin [
      (autoraise.overrideAttrs {
        buildPhase = ''
          runHook preBuild
          $CXX -std=c++03 -fobjc-arc -D"EXPERIMENTAL_FOCUS_FIRST" -D"NS_FORMAT_ARGUMENT(A)=" -D"SKYLIGHT_AVAILABLE=1" -o AutoRaise AutoRaise.mm -framework AppKit -framework SkyLight
          bash create-app-bundle.sh
          runHook postBuild
        '';
      })
      betterdisplay
      ice-bar
      rectangle
    ];
}
