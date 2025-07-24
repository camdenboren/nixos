{ ... }:

{
  system.activationScripts = {
    postActivation.text = ''
      # Following line should allow us to avoid a logout/login cycle
      sudo -u camdenboren /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
    '';
  };
}
