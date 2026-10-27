{ pkgs, ... }:

{
  environment.systemPackages = [ pkgs.xerj-bin ];

  systemd.services.xerj = {
    description = "Xerj local search engine";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];

    serviceConfig = {
      ExecStart = "${pkgs.xerj-bin}/bin/xerj --data-dir /var/lib/xerj --bind 127.0.0.1 --port 9200 --embed-mode lexical --insecure --disable-feedback";
      DynamicUser = true;
      StateDirectory = "xerj";
      StateDirectoryMode = "0750";
      WorkingDirectory = "/var/lib/xerj";
      Restart = "always";
      RestartSec = 5;
      TimeoutStopSec = 120;
      LimitNOFILE = 65536;
      NoNewPrivileges = true;
      PrivateTmp = true;
      ProtectHome = true;
      ProtectSystem = "strict";
      UMask = "0027";
    };
  };
}
