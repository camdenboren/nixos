{ ... }:

{
  boot = {
    # Bootloader
    loader.grub = {
      enable = true;
      device = "/dev/sdb";
      useOSProber = true;
    };

    # Disable ertm
    extraModprobeConfig = ''
      options bluetooth disable_ertm=1 
    '';
  };
}
