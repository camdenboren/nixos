# SPDX-FileCopyrightText: Camden Boren
# SPDX-License-Identifier: GPL-3.0-or-later

{
  nixosConfiguration,
  pkgs,
}:

pkgs.testers.runNixOSTest {
  name = "main";
  imports = [
    (import ./smoke.nix {
      inherit pkgs nixosConfiguration;
      cliChecks = [
        [
          "gh"
          "--version"
        ]
      ];
      extraApps = [
        [ "reaper" ]
        [ "steam" ]
      ];
    })
  ];

  nodes.machine = { ... }: {
    hardware.nvidia-container-toolkit.enable = pkgs.lib.mkForce false;
    services.mullvad-vpn.enable = pkgs.lib.mkForce false;
  };
}
