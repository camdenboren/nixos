{
  pkgs,
  nixosConfiguration ? null,
  darwinConfiguration ? null,
  activate ? false,

  # composable checks for each software category; only a few apps and clis are
  # tested by default-enable extras w/ `checkExtra...` or pass one-offs in w/
  # `...Checks`. bespoke tests can also be added via `extraChecks` as a string
  appChecks ? [ ],
  cliChecks ? [ ],
  serviceChecks ? [ ],
  userServiceChecks ? [ ],
  checkExtraApps ? false,
  checkExtraClis ? false,
  checkExtraServices ? false,
  checkExtraUserServices ? false,
  checkOllama ? false,
  extraChecks ? null,
}:

let
  inherit (pkgs) lib;
  mkForce = pkgs.lib.mkForce;
  isLinux = pkgs.stdenv.hostPlatform.isLinux;
  isVM = lib.hasSuffix "vm" nixosConfiguration.specialArgs.hostname;

  # identical for linux + darwin - apps + services are specified in
  # associated target-platform attrsets
  librewolfArgs = [
    "--no-remote"
    "about:blank"
  ];
  mpvArgs = [
    "--player-operation-mode=pseudo-gui"
    "--gpu-sw=yes"
  ];
  defaultClis = [
    [
      "git"
      "--version"
    ]
  ];
  extraClis = [
    [
      "gh"
      "--version"
    ]
  ];
  _cliChecks = defaultClis ++ cliChecks ++ lib.optionals checkExtraClis extraClis;
in
if isLinux then
  let
    # apps
    defaultApps = [
      {
        name = "librewolf";
        args = librewolfArgs;
        ocr = [ "New Tab" ];
      }
      {
        name = "zeditor";
        args = [ "--foreground" ];
        ocr = [ "Welcome to Zed" ];
      }
      {
        name = "ghostty";
        args = [
          "-e"
          "bash"
          "-c"
          "echo ocrpassed; sleep infinity"
        ];
        ocr = [ "ocrpassed" ];
      }
      {
        name = "nautilus";
        ocr = [ "Home" ];
      }
    ];
    extraApps = [
      {
        name = "bitwarden";
        ocr = [ "Bitwarden" ];
      }
      {
        name = "freetube";
        ocr = [ "FreeTube" ];
      }
      {
        name = "lollypop";
        ocr = [ "Lollypop" ];
      }
      {
        name = "mpv";
        args = mpvArgs;
        ocr = [ "Drop files or URLs" ];
      }
    ];
    _appChecks = defaultApps ++ appChecks ++ lib.optionals checkExtraApps extraApps;

    # services
    extraServices = [ "sshd" ];
    extraUserServices = [ "easyeffects" ];
    _serviceChecks = serviceChecks ++ lib.optionals checkExtraServices extraServices;
    _userServiceChecks = userServiceChecks ++ lib.optionals checkExtraUserServices extraUserServices;
  in
  {
    node.specialArgs = nixosConfiguration.specialArgs;
    node.pkgsReadOnly = false;
    enableOCR = true;

    nodes.machine = {
      imports = nixosConfiguration.modules ++ lib.optional (!isVM) ./support/secrets.nix;

      config = lib.mkMerge [
        {
          services = {
            displayManager.autoLogin = {
              enable = mkForce true;
              user = mkForce "camdenboren";
            };
            xserver.videoDrivers = mkForce [ "modesetting" ];
            # prevents covering zed w/ the keyring prompt
            gnome.gnome-keyring.enable = mkForce false;
          };
          systemd.services = {
            "getty@tty1".enable = mkForce false;
            "autovt@tty1".enable = mkForce false;
          };
          virtualisation = {
            memorySize = 8192;
            cores = 4;
          };

          # sd-switch's 2-minute wait and HM's 5-minute activation cap are both
          # too tight for `main`'s first-run `install-plugins` on CI.
          home-manager.users.camdenboren.systemd.user.servicesStartTimeoutMs = mkForce (15 * 60 * 1000);
          systemd.services.home-manager-camdenboren.serviceConfig.TimeoutStartSec = mkForce "15min";
        }
        (lib.mkIf (!isVM) {
          systemd.tmpfiles.rules = [
            # prevents root ownership due to mishandling in fetch-rs
            "d /home/camdenboren/.config 0755 camdenboren users -"
            "f /var/lib/clamav/test.ndb 0644 clamav clamav - TESTSIG:0:*:414243444546"
          ];

          # requires hardware or network
          power.ups.enable = mkForce false;
          services = {
            vector.enable = mkForce false;
            mullvad-vpn.enable = mkForce false;
            clamav = {
              updater.enable = mkForce false;
              fangfrisch.enable = mkForce false;
            };
          };
          systemd.user.services.refresh-references.enable = mkForce false;
          home-manager.users.camdenboren.services.syncthing.enable = mkForce false;
        })
      ];
    };

    testScript =
      let
        uid = "1000";
      in
      ''
        import datetime
        import shlex

        machine.wait_for_unit("multi-user.target")
        machine.wait_for_unit("home-manager-camdenboren.service")

        user = "camdenboren"
        rtdir = "XDG_RUNTIME_DIR=/run/user/${uid}"
        profile_path = "/home/camdenboren/.nix-profile/bin:/etc/profiles/per-user/camdenboren/bin:/run/current-system/sw/bin"

        # the driver runs as root, so GUI commands need the user session and
        # its runtime dir
        def as_user(command):
            return "su - " + user + " -c " + shlex.quote(rtdir + " " + command)

        for argv in ${builtins.toJSON _cliChecks}:
            with subtest(shlex.join(argv)):
                machine.succeed(as_user(shlex.join(["env", "PATH=" + profile_path] + argv)))

        machine.wait_for_unit("display-manager.service")
        machine.wait_for_file("/run/user/${uid}/wayland-0")
        machine.wait_until_succeeds(as_user(
            "systemctl --user is-active graphical-session.target"
        ))

        ${lib.optionalString (_serviceChecks != [ ]) ''
          for name in ${builtins.toJSON _serviceChecks}:
              unit = name + ".service"
              with subtest(name + " starts"):
                  # slow boots can drop the queued start job; starting is
                  # idempotent and still fails for broken units
                  state = machine.succeed(
                      "systemctl show --property UnitFileState --value " + unit
                  ).strip()
                  assert state not in ("disabled", "masked"), unit + " is " + state
                  machine.succeed("systemctl start " + unit)
                  machine.wait_for_unit(
                      unit,
                      timeout=datetime.timedelta(minutes=3),
                  )
        ''}

        ${lib.optionalString (_userServiceChecks != [ ]) ''
          for name in ${builtins.toJSON _userServiceChecks}:
              unit = name + ".service"
              with subtest(name + " starts"):
                  # see above
                  machine.succeed(as_user("systemctl --user start " + unit))
                  machine.wait_for_unit(
                      unit,
                      user=user,
                      timeout=datetime.timedelta(minutes=3),
                  )
        ''}

        ${lib.optionalString checkOllama ''
          with subtest("Ollama user service and API are ready"):
              try:
                  machine.wait_for_unit("ollama.service", user=user)
                  machine.wait_until_succeeds(
                      "curl --fail --silent --show-error --max-time 5 --noproxy '*' "
                      "http://127.0.0.1:11434/api/version",
                      timeout=60,
                  )
              finally:
                  print(machine.execute(as_user("journalctl --user -u ollama.service --no-pager"))[1])
        ''}

        ${lib.optionalString (extraChecks != null) extraChecks}

        # we run these last since they generally take the longest
        apps = ${builtins.toJSON _appChecks}
        for app in apps:
            name = str(app["name"])
            args = list(app.get("args", []))
            ocr = list(app.get("ocr", []))
            argv = [ name ] + args
            unit = "smoke-" + name + ".service"
            with subtest(name + " starts and stays running"):
                # use the installed user profile, not a separate copy from pkgs
                command = shlex.join([
                    "systemd-run", "--user", "--unit=" + unit,
                    "--service-type=exec",
                    "--property=TimeoutStopSec=5s",
                    "--",
                    "/run/current-system/sw/bin/env",
                    "PATH=" + profile_path,
                    "LIBGL_ALWAYS_SOFTWARE=1", "ZED_ALLOW_EMULATED_GPU=1",
                ] + argv)
                try:
                    machine.succeed(as_user(command))
                    machine.wait_for_unit(unit, user=user)
                    for text in ocr:
                        machine.wait_for_text(
                            text,
                            timeout=datetime.timedelta(minutes=30),
                        )
                    machine.succeed(as_user("systemctl --user is-active " + unit))

                finally:
                    print(machine.execute(as_user("journalctl --user -u " + unit + " --no-pager"))[1])
                    machine.screenshot("smoke-" + name)
                    machine.execute(as_user("systemctl --user stop " + unit))
      '';
  }
else
  # darwin
  { config, ... }:
  let
    user = "runner";
    home = config.home-manager.users.${user};
    packageNamed =
      name:
      lib.findFirst (
        package: lib.getName package == name
      ) (throw "Darwin smoke test: ${name} is missing from the Mac's home.packages") home.home.packages;

    defaultApps = [
      {
        package = home.programs.librewolf.package;
        bundle = "LibreWolf.app";
        args = librewolfArgs;
        ocr = [ "New Tab" ];
      }
      {
        package = home.programs.zed-editor.package;
        bundle = "Zed.app";
        ocr = [ "Welcome to Zed" ];
      }
      {
        package = home.programs.ghostty.package;
        bundle = "Ghostty.app";
        ocr = [ "shell" ];
      }
    ];
    extraApps = [
      {
        package = packageNamed "bitwarden-desktop";
        bundle = "Bitwarden.app";
        ocr = [ "Log in to Bitwarden" ];
      }
      {
        package = packageNamed "freetube";
        bundle = "FreeTube.app";
        ocr = [ "Subscriptions - FreeTube" ];
      }
      {
        package = packageNamed "reaper";
        bundle = "Reaper.app";
        ocr = [ "REAPER" ];
      }
      # unable to read the ocr for some reason-leaving in case i figure this
      # out in the future TODO
      /*
        {
        package = packageNamed "mpv-with-scripts";
        bundle = "mpv.app";
        args = mpvArgs ++ [ "--window-scale=2" ];
        ocr = [ "Drop files or URLs" ];
        }
      */
      {
        bundle = "/Applications/ClickUp.app";
        ocr = [ "Welcome back!" ];
      }
      {
        bundle = "/Applications/zoom.us.app";
        ocr = [ "Zoom Workplace" ];
      }
    ];
    _appChecks = defaultApps ++ appChecks ++ lib.optionals checkExtraApps extraApps;

    # services
    extraServices = [ ];
    extraUserServices = [ ];
    _serviceChecks = serviceChecks ++ lib.optionals checkExtraServices extraServices;
    _userServiceChecks = userServiceChecks ++ lib.optionals checkExtraUserServices extraUserServices;
  in
  {
    imports = [ ./support/secrets.nix ];

    # prevent prompting for sudo in CI w/o disabling hm activation
    options.system.activationScripts = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule (
          { name, ... }: {
            options.text = lib.mkOption {
              apply =
                if name == "postActivation" then
                  lib.replaceStrings
                    [ "sudo -u camdenboren " "/usr/sbin/sysadminctl -screenLock immediate -password -" ]
                    [ "sudo -u ${user} " ": # CI cannot supply an interactive screen-lock password" ]
                else
                  lib.id;
            };
          }
        )
      );
    };

    config = {
      # replace hardcoded username since this runs directly on the gh runner
      system.primaryUser = mkForce user;
      users.knownUsers = mkForce [ user ];
      users.users = mkForce {
        ${user} = {
          name = user;
          home = "/Users/${user}";
          inherit (darwinConfiguration.config.users.users.camdenboren) uid shell;
        };
      };
      home-manager.users = mkForce {
        ${user} = { ... }: {
          imports = [ ../hosts/mac/usr ];
          home = {
            username = mkForce user;
            homeDirectory = mkForce "/Users/${user}";
          };
        };
      };
      environment.variables.NH_FLAKE = mkForce "/Users/${user}/etc/nixos";
      services.fetch-rs = {
        user = mkForce user;
        flakePath = mkForce "/Users/${user}/etc/nixos";
      };
      sops.secrets.fetch-rs.owner = mkForce user;

      # disable tailscale, whose onboarding window obscures screenshots
      nix.enable = lib.mkIf activate (mkForce false);
      nix-homebrew.user = mkForce user;
      homebrew.casks = mkForce (
        # only feed declarative fields back into the module
        map (lib.filterAttrsRecursive (name: _: name != "_module" && name != "brewfileLine")) (
          builtins.filter (cask: cask.name != "tailscale-app") darwinConfiguration.config.homebrew.casks
        )
      );

      environment.systemPackages =
        let
          ocrHelper = ./support/darwin-ocr.swift;
          testScriptSupport = import ./support/darwin.nix { inherit user ocrHelper; };
        in
        [
          (pkgs.writeShellScriptBin "testScript" ''
            set -euo pipefail

            ${testScriptSupport}

            ${lib.concatMapStringsSep "\n" (argv: "smoke_cli ${lib.escapeShellArgs argv}") _cliChecks}

            ${lib.concatMapStringsSep "\n" (
              name:
              "smoke_service ${lib.escapeShellArg "system/${config.launchd.daemons.${name}.serviceConfig.Label}"}"
            ) _serviceChecks}

            ${lib.concatMapStringsSep "\n" (
              name:
              let
                agent = home.launchd.agents.${name};
              in
              "sudo -n /bin/launchctl print ${agent.domain}/$(id -u)/${lib.escapeShellArg agent.config.Label}"
            ) _userServiceChecks}

            ${lib.optionalString (extraChecks != null) extraChecks}

            ${lib.concatMapStringsSep "\n" (
              app:
              assert lib.assertMsg (
                app.ocr != [ ]
              ) "Darwin smoke test: ${app.bundle} requires nonempty ocr markers";
              "smoke ${
                lib.escapeShellArg (
                  if app ? package then "${app.package}/Applications/${app.bundle}" else app.bundle
                )
              } ${toString (lib.length app.ocr)} ${lib.escapeShellArgs app.ocr} -- ${
                lib.escapeShellArgs (app.args or [ ])
              }"
            ) _appChecks}
          '')
        ];
    };
  }
