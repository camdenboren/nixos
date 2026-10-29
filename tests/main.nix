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
      extraApps = [
        [
          "reaper"
          "bitwarden"
        ]
      ];
      checkOllama = true;
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

  testScript = pkgs.lib.mkAfter ''
    machine.wait_for_unit("default.target", user="camdenboren")

    for unit in ["install-plugins.service", "replace-configs.service"]:
        with subtest(unit + " completed successfully"):
            info = machine.get_unit_info(unit, user="camdenboren")
            assert info["ExecMainStartTimestampMonotonic"] != "0", info
            assert info["ActiveState"] == "inactive", info
            assert info["Result"] == "success", info
            assert info["ExecMainStatus"] == "0", info

    machine.succeed("test -s /home/camdenboren/.config/REAPER/reaper.ini")
  '';
}
