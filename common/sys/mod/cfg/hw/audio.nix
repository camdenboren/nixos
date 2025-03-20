{ hostname, ... }:

let
  isMain = (hostname == "main");
in
{
  services.pulseaudio.enable = false;
  security.rtkit.enable = (!isMain);
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };
}
// (
  if isMain then
    {
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
  else
    { }
)
