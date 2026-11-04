{
  nixosConfiguration,
  pkgs,
  # false when `nixosConfiguration` omits the InvokeAI module (see `mainci` in flake.nix)
  withInvokeai ? true,
}:

let
  inherit (pkgs) lib;
  inherit (lib) mkForce;
in
pkgs.testers.runNixOSTest {
  name = "main";
  imports = [
    (import ../smoke.nix {
      inherit pkgs nixosConfiguration;
      appChecks = [
        {
          name = "reaper";
          ocr = [ "Scanning VST" ];
        }
      ];
      checkExtraApps = true;
      checkExtraClis = true;
      checkOllama = true;
      checkExtraServices = true;
      checkExtraUserServices = true;
      serviceChecks = [ "xerj" ] ++ lib.optionals withInvokeai [ "podman-invokeai-invokeai-cuda" ];
      extraChecks = ''
        # oneshot user services create the expected resources
        with subtest("replace-configs prepares `reaper.ini`"):
            machine.succeed("test -s /home/camdenboren/.config/REAPER/reaper.ini")

        with subtest("install-plugins prepares Wine prefix"):
            machine.succeed("test -d /home/camdenboren/.wine/drive_c/windows/system32")
            machine.succeed("test -f /home/camdenboren/.wine/drive_c/windows/system32/dxgi.dll")
            machine.succeed("test -L /home/camdenboren/.wine/drive_c/ProgramData/MeldaProduction")
      '';
    })
  ];

  nodes.machine = {
    # no gpu
    hardware.nvidia-container-toolkit.enable = mkForce false;

    # the InvokeAI container bind-mounts these host paths, and podman refuses
    # to start if they're missing
    systemd.tmpfiles.rules = lib.optionals withInvokeai [
      "d /home/camdenboren/.cache 0755 camdenboren users -"
      "d /home/camdenboren/.cache/huggingface 0755 camdenboren users -"
      "d /home/camdenboren/invokeai 0755 camdenboren users -"
    ];

    # the CUDA device needs the nvidia CDI spec, which this VM lacks; keep in
    # sync with the other options in hosts/main/sys/mod/pkgs/srv/invokeai.nix
    virtualisation.oci-containers.containers = lib.optionalAttrs withInvokeai {
      "invokeai-invokeai-cuda".extraOptions = mkForce [
        "--network-alias=invokeai-cuda"
        "--network=invokeai_default"
      ];
    };

    # podman unpacks the ~9.6 GB InvokeAI archive onto the disk while loading
    # it; <25 GB ran out of space mid-run
    virtualisation.diskSize = lib.mkIf withInvokeai (32 * 1024);
  };
}
