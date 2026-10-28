# SPDX-FileCopyrightText: Camden Boren
# SPDX-License-Identifier: GPL-3.0-or-later

{
  nixosConfiguration,
  pkgs,
}:

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
      extraApps = [ [ "steam" ] ];
    })
  ];

  nodes.machine = { ... }: {
    services.tailscale.enable = pkgs.lib.mkForce false;
    services.mullvad-vpn.enable = pkgs.lib.mkForce false;
  };

  # Check the real nginx configuration without requiring proxied applications
  # or production credentials. Draw.io is served directly from the Nix store.
  testScript = pkgs.lib.mkAfter ''
    with subtest("nginx serves HTTP redirects and static HTTPS content"):
        machine.wait_for_unit("nginx.service")
        machine.wait_for_open_port(80)
        machine.wait_for_open_port(443)
        machine.succeed(
            "curl --silent --show-error --max-time 30 --noproxy '*' "
            "--resolve home.local:80:127.0.0.1 "
            "--output /dev/null --write-out '%{http_code}' http://home.local/ "
            "| grep -Fx 301"
        )
        machine.succeed(
            "curl --fail --silent --show-error --max-time 30 --noproxy '*' "
            "--resolve draw.home.local:443:127.0.0.1 "
            "--cacert /var/lib/acme/home.local/chain.pem "
            "https://draw.home.local/ --output /tmp/nginx-smoke.html"
        )
        machine.succeed("test -s /tmp/nginx-smoke.html")
  '';
}
