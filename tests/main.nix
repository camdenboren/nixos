# SPDX-FileCopyrightText: Camden Boren
# SPDX-License-Identifier: GPL-3.0-or-later

{
  nixosConfiguration,
  pkgs,
}:

let
  mkForce = pkgs.lib.mkForce;
in
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
      checkExtraApps = true;
      appChecks = [
        [ "reaper" ]
      ];
      checkOllama = true;
      serviceChecks = [
        "install-plugins"
        "replace-configs"
        "xerj"
      ];
      extraServiceChecks = ''
        machine.succeed("test -s /home/camdenboren/.config/REAPER/reaper.ini")
      '';
    })
  ];

  nodes.machine = {
    # no gpu
    hardware.nvidia-container-toolkit.enable = mkForce false;

    # likewise, though i'll package these images in the future w/ `pull =
    # "never"";`
    systemd.services = {
      podman-invokeai-invokeai-cuda.enable = mkForce false;
      podman-network-invokeai_default.enable = mkForce false;
      podman-build-invokeai-invokeai-cuda.enable = mkForce false;
    };
  };
}
