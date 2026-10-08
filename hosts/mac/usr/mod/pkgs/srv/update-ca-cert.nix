{
  config,
  pkgs,
  pkgs-stable,
  ...
}:

let
  script = pkgs.writeShellScriptBin "update-ca-cert" ''
    if test -f ~/.config/gam/gam.cfg; then
      ${pkgs.gnused}/bin/sed -i \
        "s|^\(cacerts_pem\s*=\s*\).*|\1${pkgs-stable.cacert}/etc/ssl/certs/ca-bundle.crt|" \
        ~/.config/gam/gam.cfg
    fi
  '';
  logPath = "${config.home.homeDirectory}/Library/Logs/update-ca-cert.log";
in
{
  # Points gam at the nixpkgs CA bundle at load.
  launchd.agents.update-ca-cert = {
    enable = true;
    config = {
      ProgramArguments = [ "${script}/bin/update-ca-cert" ];
      RunAtLoad = true;
      StandardOutPath = logPath;
      StandardErrorPath = logPath;
    };
  };
}
