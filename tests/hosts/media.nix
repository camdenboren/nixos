{
  nixosConfiguration,
  pkgs,
}:

let
  mkForce = pkgs.lib.mkForce;
  library = pkgs.writeText "library.xml" ''
    <?xml version="1.0" encoding="UTF-8"?>
    <library version="20110515"/>
  '';
in
pkgs.testers.runNixOSTest {
  name = "media";
  imports = [
    (import ../smoke.nix {
      inherit pkgs nixosConfiguration;
      checkExtraApps = true;
      checkExtraClis = true;
      checkExtraServices = true;
      checkExtraUserServices = true;
      checkOllama = true;
      serviceChecks = [
        "actual"
        "dex"
        "homebox"
        "homepage-dashboard"
        "immich-machine-learning"
        "immich-server"
        "jellyfin"
        "kiwix-mcp"
        "kiwix-serve"
        "lubelogger"
        "nginx"
        "ntfy-sh"
        "omdb-lookup"
        "open-webui"
        "openobserve"
        "opengist"
        "outline"
        "podman-penpot-penpot-frontend"
        "podman-readest-client"
        "postgresql"
        "redis-immich"
        "redis-outline"
        "vaultwarden"
        "xerj"
      ];
      extraChecks = ''
        with subtest("nginx serves Draw.io over HTTPS"):
            machine.wait_for_unit("nginx.service")
            machine.wait_for_open_port(443)
            machine.succeed(
                "curl --fail --silent --show-error --max-time 30 "
                "--noproxy '*' "
                "--resolve draw.home.local:443:127.0.0.1 "
                "--cacert /var/lib/acme/home.local/chain.pem "
                "https://draw.home.local/ --output /tmp/draw-smoke.html"
            )
            machine.succeed("test -s /tmp/draw-smoke.html")

        with subtest("Opengist responds through its proxied vhost"):
            machine.wait_for_unit("opengist.service")
            machine.wait_for_open_port(6157, "127.0.0.1")
            machine.succeed(
                "curl --fail --silent --show-error --max-time 30 "
                "--noproxy '*' "
                "--resolve gist.home.local:443:127.0.0.1 "
                "--cacert /var/lib/acme/home.local/chain.pem "
                "https://gist.home.local/healthcheck"
            )

        with subtest("Readest responds through its proxied vhost"):
            machine.wait_for_unit("podman-readest-client.service")
            machine.wait_for_open_port(443)
            machine.wait_until_succeeds(
                "curl --fail --silent --show-error --max-time 30 "
                "--noproxy '*' "
                "--resolve read.home.local:443:127.0.0.1 "
                "--cacert /var/lib/acme/home.local/chain.pem "
                "https://read.home.local/runtime-config.js "
                "| grep -q 'read.home.local'",
                timeout=180,
            )
      '';
    })
  ];

  nodes.machine = {
    systemd.tmpfiles.rules = [
      "C /var/lib/kiwix/library.xml 0444 root root - ${library}"
    ];

    virtualisation = {
      # podman unpacks the loaded Penpot archives (~3.4 GB), the Readest
      # Supabase/RustFS/client images, and Jellyfin's data onto the disk.
      diskSize = mkForce (20 * 1024);

      # penpot unpacks while postgres/immich/open-webui initialize; 12 GB would
      # leave the 27 GB CI builder too little slack
      memorySize = mkForce (10 * 1024);

      # the VM has no DNS, so the frontend's nginx exits resolving its external
      # upstream at startup and systemd restart-loops it; resolve it locally
      oci-containers.containers.penpot-penpot-frontend.extraOptions = [
        "--add-host=raw.githubusercontent.com:127.0.0.1"
      ];
    };

    services = {
      # no secondary hard drive
      kiwix-serve.libraryPath = mkForce "/var/lib/kiwix/library.xml";

      # requires network
      unbound.enable = mkForce false;
      tailscale.enable = mkForce false;
    };
  };
}
