{ pkgs, config, ... }:

{
  users.users.omdb-lookup = {
    isSystemUser = true;
    group = "omdb-lookup";
  };
  users.groups.omdb-lookup = { };

  systemd.services.omdb-lookup = {
    enable = true;
    description = "Worker for a simple widget to retrieve the top result for a given name and title from the OMDb API";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];

    serviceConfig = {
      Restart = "always";
      ExecStart = "${pkgs.workerd}/bin/workerd serve ${pkgs.omdb-lookup}/config.capnp";
      User = "omdb-lookup";
      Group = "omdb-lookup";
      EnvironmentFile = config.sops.secrets.omdb-lookup.path;
      NoNewPrivileges = true;
      PrivateTmp = true;
      ProtectHome = true;
      ProtectSystem = "strict";
      UMask = "0027";
    };
  };
}
