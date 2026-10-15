{ pkgs, ... }:

{
  systemd.services.home-manager-restart = {
    description = "Restart Home Manager after NixOS activation";

    requiredBy = [ "sysinit-reactivation.target" ];
    before = [ "sysinit-reactivation.target" ];

    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.systemd}/bin/systemctl restart home-manager-camdenboren.service";
      NoNewPrivileges = true;
      PrivateTmp = true;
      ProtectControlGroups = true;
      ProtectHome = true;
      ProtectKernelModules = true;
      ProtectKernelTunables = true;
      ProtectSystem = true;
      LockPersonality = true;
      RestrictRealtime = true;
      RestrictSUIDSGID = true;
    };
  };
}
