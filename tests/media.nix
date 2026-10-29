# SPDX-FileCopyrightText: Camden Boren
# SPDX-License-Identifier: GPL-3.0-or-later

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
    (import ./smoke.nix {
      inherit pkgs nixosConfiguration;
      cliChecks = [
        [
          "gh"
          "--version"
        ]
      ];
      checkOllama = true;
    })
  ];

  nodes.machine = {
    imports = [ ./secrets.nix ];

    # jellyfin hard-codes a 2gb free-space minimum on its data dir
    virtualisation.diskSize = 3 * 1024; # 3gb

    systemd.tmpfiles.rules = [
      "C /var/lib/kiwix/library.xml 0444 root root - ${library}"
    ];

    # no secondary hard drive
    services.kiwix-serve.libraryPath = mkForce "/var/lib/kiwix/library.xml";

    # requires network
    services.unbound.enable = mkForce false;
    services.tailscale.enable = mkForce false;

    # likewise, though i'll package these images in the future w/ `pull =
    # "never"";`
    systemd.services = {
      podman-penpot-penpot-backend.enable = mkForce false;
      podman-penpot-penpot-exporter.enable = mkForce false;
      podman-penpot-penpot-frontend.enable = mkForce false;
      podman-penpot-penpot-mailcatch.enable = mkForce false;
      podman-penpot-penpot-postgres.enable = mkForce false;
      podman-penpot-penpot-valkey.enable = mkForce false;
      podman-network-penpot_penpot.enable = mkForce false;
      podman-volume-penpot_penpot_assets.enable = mkForce false;
      podman-volume-penpot_penpot_postgres_v15.enable = mkForce false;
    };
  };

  # in addition to non-service items in smoke.nix
  testScript = pkgs.lib.mkAfter (
    { nodes, ... }:
    let
      candidates = [
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
        "open-webui"
        "openobserve"
        "outline"
        "postgresql"
        "redis-immich"
        "redis-outline"
        "xerj"
      ];

      enabled = builtins.filter (name: nodes.machine.systemd.services.${name}.enable or false) candidates;
    in
    ''
      import datetime

      for name in ${builtins.toJSON enabled}:
          with subtest(name + " starts"):
              machine.wait_for_unit(
                  name + ".service",
                  timeout=datetime.timedelta(minutes=3),
              )

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
    ''
  );
}
