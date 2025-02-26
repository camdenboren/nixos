{ ... }:

{
  # Enable sound with pipewire
  services.pulseaudio.enable = false;
  security.rtkit.enable = false; # true causes yabridge warning about rttime. trying false - can give stability issues
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable Musnix, customize some PAM limits
  musnix.enable = true;
  security.pam.loginLimits = [
    {
      domain = "@audio";
      item = "nofile";
      type = "soft";
      value = "unlimited";
    }
    {
      domain = "@audio";
      item = "nofile";
      type = "hard";
      value = "unlimited";
    }
  ];
}
