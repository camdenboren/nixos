{ pkgs, ... }:

{
  # add new zims via:
  # $(cd /mnt/media/Archives && kiwix-manage library.xml add file.zim)
  services.kiwix-serve = {
    enable = true;
    port = 9095;
    libraryPath = "/mnt/media/Archives/library.xml";
  };

  # MCP server
  systemd.services.kiwix-mcp = {
    enable = true;
    description = "kiwix-mcp service";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    environment = {
      KIWIX_BASE_URL = "http://localhost:9095";
    };

    serviceConfig = {
      Restart = "always";
      ExecStart = "${pkgs.kiwix-mcp}/bin/kiwix-mcp --transport streamable-http";
      DynamicUser = true;
      UMask = "0027";
    };
  };
}
