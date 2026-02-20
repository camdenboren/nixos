{ lib, config, ... }:

{
  system.activationScripts = {
    # Avoid a logout/login cycle for changes to take effect
    postActivation.text = ''
      sudo -u camdenboren /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
    '';

    # Enable low power mode on battery
    # adapted from https://github.com/wwmoraes/dotfiles/blob/763f129b7f516a7485a52559916c724b0bc96474/modules/nix-darwin/system/pmset.nix
    extraActivation.text = lib.mkAfter config.system.activationScripts.pmset.text;
    pmset.text = ''
      pmset -b powermode 1
    '';
  };
}
