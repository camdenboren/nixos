{ ... }:

{
  programs.gnome-terminal = {
    enable = true;
    profile.db844b4d-3964-4927-b431-58d2424b7f86 = {
      audibleBell = false;
      default = true;
      showScrollbar = false;
      visibleName = "Code Red";
    };
  };
}
