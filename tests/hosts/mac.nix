# extend the real Mac host and exercise it on an ephemeral runner
{
  darwinConfiguration,
  activate ? false,
}:

darwinConfiguration.extendModules {
  modules = [
    (import ../smoke.nix {
      inherit (darwinConfiguration) pkgs;
      inherit darwinConfiguration activate;
      checkExtraApps = true;
      checkExtraClis = true;
      cliChecks = [
        [
          "/usr/bin/ssh"
          "-V"
        ]
        [
          "gam"
          "version"
          "simple"
        ]
      ];
      serviceChecks = [
        "chatbot-util"
        "xerj"
      ];
      extraChecks = ''
        # oneshot user services create the expected resources
        echo "Checking replace-configs prepares app workflows"
        test -s "$HOME/Library/Services/LaunchGhostty.workflow/Contents/document.wflow"
        test -s "$HOME/Library/Services/LaunchGhostty.workflow/Contents/Info.plist"
      '';
    })
    ({ lib, ... }: {
      home-manager.sharedModules = [
        { launchd.agents.refresh-references.enable = lib.mkForce false; }
      ];
    })
  ];
}
