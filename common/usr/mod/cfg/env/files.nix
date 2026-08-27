{
  pkgs,
  lib,
  hostname,
  system,
  ...
}:

let
  jsonFormat = pkgs.formats.json { };
  isDarwin = lib.hasSuffix "-darwin" system;
  mcp = import ../../../dot/agents/mcp.nix { inherit pkgs; };
  gui-settings = import ../../../dot/Mullvad_VPN/gui-settings.nix { inherit hostname; };
in
{
  home.file = {
    # Autoloaded by tools like Zed and Pi
    ".agents/skills/kiwix-mcp-usage/SKILL.md" = {
      source = ../../../dot/agents/skills/kiwix-mcp-usage.md;
    };
    ".codex/skills/kiwix-mcp-usage/SKILL.md" = lib.mkIf isDarwin {
      source = ../../../dot/agents/skills/kiwix-mcp-usage.md;
    };
    ".agents/mcp.json" = {
      source = jsonFormat.generate "mcp" mcp;
    };

    # Lynx config
    ".config/lynx/lynx.cfg" = {
      source = ../../../dot/lynx/lynx.cfg;
    };
    ".config/lynx/lynx.lss" = {
      source = ../../../dot/lynx/lynx.lss;
    };

    # Mullvad VPN GUI Config. Deeper settings in configuration.nix
    ".config/Mullvad VPN/gui_settings.json" = lib.mkIf (hostname == "main" || hostname == "media") {
      source = jsonFormat.generate "gui_settings" gui-settings;
    };
  };
}
