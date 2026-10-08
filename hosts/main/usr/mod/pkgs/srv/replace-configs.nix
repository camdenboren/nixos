{ pkgs, ... }:

let
  script = pkgs.writeShellScriptBin "replace-configs" ''
    if ! test -f ~/.config/REAPER/reaper.ini; then
      ${pkgs.coreutils}/bin/mkdir -p ~/.config/REAPER
      ${pkgs.coreutils}/bin/cp -r ~/etc/nixos/hosts/main/usr/dot/reaper/reaper.ini ~/.config/REAPER
    fi
  '';
in
{
  # Installs the default REAPER config at login if missing.
  systemd.user.services.replace-configs = {
    Unit.Description = "Install default REAPER config if missing";
    Service = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${script}/bin/replace-configs";
      NoNewPrivileges = true;
      PrivateTmp = true;
      ProtectSystem = true;
      UMask = "0027";
    };
    Install.WantedBy = [ "default.target" ];
  };
}
