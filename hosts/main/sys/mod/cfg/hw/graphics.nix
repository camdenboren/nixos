{ config, ... }:

{
  # NVIDIA Driver
  hardware = {
    graphics = {
      enable = true;
      enable32Bit = true;
    };

    nvidia = {
      modesetting.enable = true;
      powerManagement.enable = false;
      powerManagement.finegrained = false;
      open = false;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.latest;
    };

    nvidia-container-toolkit.enable = true;
  };

  services.xserver.videoDrivers = [ "nvidia" ];
}
