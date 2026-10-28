# SPDX-FileCopyrightText: Camden Boren
# SPDX-License-Identifier: GPL-3.0-or-later

# Extend the real Mac host, activate it on an ephemeral runner, then exercise
# accounts, Home Manager, defaults, launchd jobs, and app startup.
{
  darwinConfiguration,
  activate ? false,
}:

let
  pkgs = darwinConfiguration.pkgs;
  inherit (pkgs) lib;
  config = testConfiguration.config;
  user = config.system.primaryUser;
  home = config.home-manager.users.${user};
  marker = "${home.home.homeDirectory}/.local/state/nixos-smoke/activated";
  testConfiguration = darwinConfiguration.extendModules {
    modules = [
      {
        # Isolate all CI adaptations here: the host files remain unchanged.
        disabledModules = [
          ../hosts/mac/sys/mod/cfg/def/users.nix
          ../hosts/mac/sys/mod/cfg/env/activation.nix
        ];
        system.primaryUser = lib.mkForce "runner";
        users.knownUsers = [ "runner" ];
        users.users.runner = {
          name = "runner";
          home = "/Users/runner";
          inherit (darwinConfiguration.config.users.users.camdenboren) uid shell;
        };
        imports = [
          (import ./smoke.nix {
            inherit pkgs;
            darwinConfiguration = testConfiguration;
            activationMarker = marker;
            cliChecks = [
              [
                "gam"
                "version"
                "simple"
              ]
              [
                "gh"
                "--version"
              ]
            ];
          })
        ];

        # Preserve the runner's Nix and Homebrew installations. The host's full
        # Homebrew cask list and its activation still apply.
        nix.enable = lib.mkIf activate (lib.mkForce false);
        nix-homebrew.enable = lib.mkForce false;
        nix-homebrew.user = lib.mkForce "runner";
        homebrew.onActivation.autoUpdate = lib.mkForce false;
        homebrew.onActivation.cleanup = lib.mkForce "none";

        # CI cannot supply personal secrets, interactive passwords, battery
        # hardware, or firmware access. Do not replace postActivation: it also
        # contains the real Home Manager activation.
        services.fetch-rs.enable = lib.mkForce false;
        sops.secrets = lib.mkForce { };
        # The excluded activation module contains the hardcoded personal user,
        # screen-lock password prompt, and battery settings. Keep its safe
        # settings refresh, merged with (not replacing) HM's postActivation.
        system.activationScripts.postActivation.text = ''
          sudo -u runner /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
        '';
        system.activationScripts.power.text = lib.mkForce "";
        system.keyboard.enableKeyMapping = lib.mkForce false;
        system.keyboard.remapCapsLockToEscape = lib.mkForce false;
        system.startup.chime = lib.mkForce null;

        # Replace the personal HM key, but evaluate the same host modules and
        # inherited extraSpecialArgs with only the account identity overridden.
        home-manager.users = lib.mkForce {
          runner = { lib, ... }: {
            imports = [ ../hosts/mac/usr ];
            home.username = lib.mkForce "runner";
            home.homeDirectory = lib.mkForce "/Users/runner";
            launchd.agents.refresh-references.enable = lib.mkForce false;
            home.activation.smokeMarker = lib.hm.dag.entryAfter [ "setupLaunchAgents" ] ''
              run mkdir -p ${lib.escapeShellArg (dirOf marker)}
              run touch ${lib.escapeShellArg marker}
            '';
          };
        };
      }
    ];
  };
in
testConfiguration
