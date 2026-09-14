{ lib, config, ... }:

let
  sleepTime = "30";
  lockTime = "immediate";
in
{
  system.activationScripts = {
    postActivation.text = ''
      # Avoid a logout/login cycle for changes to take effect
      sudo -u camdenboren /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u

      # Set the screenLock delay via `sysadminctl`, which, as it requires
      # entering an interactive password, is only set when the value needs
      # correcting as we'd otherwise have to enter the password one more time
      # for each rebuild.
      if ! /usr/sbin/sysadminctl -screenLock status 2>&1 | grep -q 'screenLock delay is ${lockTime}'; then
        /usr/sbin/sysadminctl -screenLock ${lockTime} -password -
      fi
    '';

    extraActivation.text = lib.mkAfter config.system.activationScripts.pmset.text;
    pmset.text = ''
      # Enable low power mode on battery, adapted from:
      # https://github.com/wwmoraes/dotfiles/blob/763f129b7f516a7485a52559916c724b0bc96474/modules/nix-darwin/system/pmset.nix
      pmset -b powermode 1

      # Set the sleep/lock time when on battery since `power.sleep.*` only
      # affects AC
      pmset -b displaysleep ${sleepTime} sleep ${sleepTime}
    '';
  };
}
