{ rice, ... }:

{
  system.activationScripts = {
    postUserActivation.text = ''
      # Following line should allow us to avoid a logout/login cycle
      /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u

      # set the wallpaper to rice
      /usr/local/bin/desktoppr "/Users/camdenboren/etc/nixos/common/usr/rice/wallpapers/${rice}.jpg"
    '';
  };
}
