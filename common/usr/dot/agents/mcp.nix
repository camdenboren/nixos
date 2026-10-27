{ pkgs, ... }:

{
  mcpServers = {
    kiwix-mcp = {
      command = "${pkgs.kiwix-mcp}/bin/kiwix-mcp";
      env = {
        KIWIX_BASE_URL = "https://archive.home.local";
      };
    };
    xerj = {
      command = "${pkgs.xerj-bin}/bin/xerj";
      args = [ "mcp" ];
    };
  };
}
