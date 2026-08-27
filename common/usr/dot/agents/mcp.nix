{ pkgs, ... }:

{
  mcpServers = {
    kiwix-mcp = {
      command = "${pkgs.kiwix-mcp}/bin/kiwix-mcp";
      env = {
        KIWIX_BASE_URL = "https://archive.home.local";
      };
    };
  };
}
