{ config, lib, ... }:

let
  agents = lib.filterAttrs (_: agent: agent.enable) config.launchd.agents;
in
{
  # ensure configs are kept in sync by rerunning unchanged, loaded agents; HM
  # automatically restarts changed agents, so that case is ignored
  home.activation.kickstartAgents =
    lib.hm.dag.entryBetween
      [ "setupLaunchAgents" ]
      [
        "installPackages"
        "linkGeneration"
        "onFilesChange"
      ]
      (
        lib.concatStringsSep "\n" (
          lib.mapAttrsToList (_: agent: ''
            agent=${lib.escapeShellArg agent.config.Label}
            target=${lib.escapeShellArg agent.domain}/$UID/"$agent"
            if /usr/bin/cmp -s "$newGenPath/LaunchAgents/$agent.plist" "${config.home.homeDirectory}/Library/LaunchAgents/$agent.plist" \
              && /bin/launchctl print "$target" >/dev/null 2>&1; then
              run /bin/launchctl kickstart "$target"
            fi
          '') agents
        )
      );
}
