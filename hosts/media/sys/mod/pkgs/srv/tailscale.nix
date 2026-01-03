{ ... }:

{
  services.tailscale = {
    enable = true;
    # comment this out on first run
    authKeyFile = "/var/lib/secrets/tailscale";
    extraDaemonFlags = [ "--no-logs-no-support" ];
  };
}
