{ config, ... }:

let
  sleepTime = "30";
  lockTime = "immediate";
in
{
  # Applies power and system settings without requiring logout/login. The
  # screenLock delay needs an interactive password, so only drift is logged.
  launchd.daemons.macos-settings = {
    script = ''
      # Avoid a logout/login cycle for changes to take effect
      /usr/bin/sudo -u camdenboren /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u

      # `power.sleep.*` only covers AC; battery behavior is set here.
      /usr/bin/pmset -b powermode 1
      /usr/bin/pmset -b displaysleep ${sleepTime} sleep ${sleepTime}

      if ! /usr/sbin/sysadminctl -screenLock status 2>&1 | /usr/bin/grep -q 'screenLock delay is ${lockTime}'; then
        echo "screenLock delay is not '${lockTime}'. Run interactively:" >&2
        echo "  sudo /usr/sbin/sysadminctl -screenLock ${lockTime} -password -" >&2
      fi
    '';
    serviceConfig = {
      RunAtLoad = true;
      # Reload after any defaults change; the plist is otherwise static.
      # `alf` is excluded: upstream removed the option and forcing it
      # fails evaluation.
      EnvironmentVariables.NIXDARWIN_DEFAULTS_HASH =
        let
          defaults = removeAttrs config.system.defaults [ "alf" ];
        in
        builtins.hashString "sha256" (builtins.toJSON defaults);
    };
  };
}
