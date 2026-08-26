{ pkgs, ... }:

{
  # restart home-manager on every rebuild, see
  # https://github.com/nix-community/home-manager/issues/7166
  system.activationScripts = {
    home-manager-restart = {
      text = ''
        ${pkgs.systemd}/bin/systemctl restart home-manager-camdenboren.service || true
      '';
      deps = [
        "users"
        "groups"
      ];
    };
  };
}
