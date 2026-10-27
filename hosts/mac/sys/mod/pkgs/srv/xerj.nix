{
  config,
  lib,
  pkgs,
  ...
}:

let
  user = config.system.primaryUser;
  dataDir = "/var/lib/xerj";
  logPath = "/var/log/xerj.log";
in
{
  environment.systemPackages = [ pkgs.xerj-bin ];
  environment.variables.XERJ_URL = "http://127.0.0.1:9200";

  system.activationScripts.preActivation.text = ''
    ${pkgs.coreutils}/bin/install -d -m 0750 -o ${lib.escapeShellArg user} -g staff ${dataDir}
    ${pkgs.coreutils}/bin/touch ${logPath}
    ${pkgs.coreutils}/bin/chown ${lib.escapeShellArg user}:staff ${logPath}
    ${pkgs.coreutils}/bin/chmod 0640 ${logPath}
  '';

  launchd.daemons.xerj = {
    serviceConfig = {
      ProgramArguments = [
        "${pkgs.xerj-bin}/bin/xerj"
        "--data-dir"
        dataDir
        "--bind"
        "127.0.0.1"
        "--port"
        "9200"
        "--embed-mode"
        "lexical"
        "--insecure"
        "--disable-feedback"
      ];
      UserName = user;
      GroupName = "staff";
      WorkingDirectory = dataDir;
      RunAtLoad = true;
      KeepAlive = true;
      ThrottleInterval = 5;
      ExitTimeOut = 120;
      Umask = 23; # 0027
      SoftResourceLimits.NumberOfFiles = 65536;
      HardResourceLimits.NumberOfFiles = 65536;
      StandardOutPath = logPath;
      StandardErrorPath = logPath;
    };
  };
}
