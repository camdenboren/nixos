{ pkgs, ... }:

let
  script = pkgs.writeShellScriptBin "fix-panel" ''
    ${pkgs.gnome-shell}/bin/gnome-extensions disable blur-my-shell@aunetx
    ${pkgs.gnome-shell}/bin/gnome-extensions enable blur-my-shell@aunetx
  '';
in
{
  # Re-toggles blur-my-shell so the panel blurs on the correct monitor.
  systemd.user.services.fix-panel = {
    Unit = {
      Description = "Fix blur-my-shell panel width";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${script}/bin/fix-panel";
      NoNewPrivileges = true;
      PrivateTmp = true;
      ProtectSystem = true;
      UMask = "0027";
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };
}
