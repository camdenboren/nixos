# SPDX-FileCopyrightText: Camden Boren
# SPDX-License-Identifier: GPL-3.0-or-later

{
  nixosConfiguration,
  pkgs,
}:

pkgs.testers.runNixOSTest {
  name = "macvm";
  imports = [
    (import ./smoke.nix {
      inherit pkgs nixosConfiguration;
    })
  ];
}
