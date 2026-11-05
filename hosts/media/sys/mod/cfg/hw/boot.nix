_:

{
  boot = {
    # Bootloader
    loader.grub = {
      enable = true;
      # specify the actual drive id to prevent boot loader mismatches when
      # switching due to uncertainty re. naming (e.g., sdb sometimes points to
      # `/mnt/media` instead)
      device = "/dev/disk/by-id/ata-Samsung_SSD_860_EVO_500GB_S598NE0M908187T";
      useOSProber = true;
    };

    # Disable ertm
    extraModprobeConfig = ''
      options bluetooth disable_ertm=1
    '';
  };
}
