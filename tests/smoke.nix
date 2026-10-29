# SPDX-FileCopyrightText: Camden Boren
# SPDX-License-Identifier: GPL-3.0-or-later

{
  pkgs,
  nixosConfiguration ? null,
  darwinConfiguration ? null,
  activationMarker ? null,
  extraApps ? [ ],
  cliChecks ? [ ],
  checkOllama ? false,
}:

let
  inherit (pkgs) lib;
  mkForce = pkgs.lib.mkForce;
  isLinux = pkgs.stdenv.hostPlatform.isLinux;
  isVM = lib.hasSuffix "vm" nixosConfiguration.specialArgs.hostname;
in
if isLinux then
  {
    node.specialArgs = nixosConfiguration.specialArgs;
    node.pkgsReadOnly = false;

    nodes.machine = {
      imports = nixosConfiguration.modules ++ lib.optional (!isVM) ./secrets.nix;

      config = lib.mkMerge [
        {
          services.displayManager.autoLogin = {
            enable = mkForce true;
            user = mkForce "camdenboren";
          };
          services.xserver.videoDrivers = mkForce [ "modesetting" ];
          systemd.services."getty@tty1".enable = mkForce false;
          systemd.services."autovt@tty1".enable = mkForce false;
          virtualisation.memorySize = 8192;
          virtualisation.cores = 4;

          # prevents covering zed w/ the keyring prompt
          services.gnome.gnome-keyring.enable = mkForce false;
        }
        (lib.mkIf (!isVM) {
          systemd.tmpfiles.rules = [
            # prevents root ownership due to mishandling in fetch-rs
            "d /home/camdenboren/.config 0755 camdenboren users -"
            "f /var/lib/clamav/test.ndb 0644 clamav clamav - TESTSIG:0:*:414243444546"
          ];

          # requires hardware or network
          power.ups.enable = mkForce false;
          services.vector.enable = mkForce false;
          services.mullvad-vpn.enable = mkForce false;
          systemd.user.services.refresh-references.enable = mkForce false;
          services.clamav = {
            updater.enable = mkForce false;
            fangfrisch.enable = mkForce false;
          };
          home-manager.users.camdenboren.services.syncthing.enable = mkForce false;
        })
      ];
    };

    testScript = ''
      import shlex

      machine.start()
      machine.wait_for_unit("multi-user.target")

      user = "camdenboren"

      def as_user(command):
          return "su -l " + user + " --shell /bin/sh -c " + shlex.quote(
              'export XDG_RUNTIME_DIR="/run/user/$(id -u)"; ' + command
          )

      machine.wait_for_unit("home-manager-" + user + ".service")
      profile_path = "/home/" + user + "/.nix-profile/bin:/etc/profiles/per-user/" + user + "/bin:/run/current-system/sw/bin"
      for argv in ${builtins.toJSON cliChecks}:
          with subtest(shlex.join(argv)):
              machine.succeed(as_user(shlex.join(["env", "PATH=" + profile_path] + argv)))

      machine.wait_for_unit("display-manager.service")
      machine.wait_until_succeeds(as_user(
          "systemctl --user is-active graphical-session.target"
      ))
      # GNOME imports its display environment into the user manager on login.
      machine.wait_until_succeeds(as_user(
          "systemctl --user show-environment | grep -q '^WAYLAND_DISPLAY='"
      ))

      apps = ${
        builtins.toJSON (
          [
            [
              "librewolf"
              "--no-remote"
              "about:blank"
            ]
            [
              "zeditor"
              "--foreground"
            ]
            [ "ghostty" ]
          ]
          ++ extraApps
        )
      }

      ${lib.optionalString checkOllama ''
        with subtest("Ollama user service and API are ready"):
            try:
                machine.wait_for_unit("ollama.service", user=user)
                machine.wait_until_succeeds(
                    "curl --fail --silent --show-error --max-time 5 --noproxy '*' "
                    "http://127.0.0.1:11434/api/version",
                    timeout=120,
                )
            finally:
                print(machine.execute(as_user("journalctl --user -u ollama.service --no-pager"))[1])
      ''}

      for argv in apps:
          name = argv[0]
          unit = "smoke-" + name + ".service"
          with subtest(name + " starts and stays running"):
              # Use the installed user profile, not a separate copy from pkgs.
              command = shlex.join([
                  "systemd-run", "--user", "--unit=" + unit,
                  "--service-type=exec", "--",
                  "/run/current-system/sw/bin/env",
                  "PATH=" + profile_path,
                  "LIBGL_ALWAYS_SOFTWARE=1", "ZED_ALLOW_EMULATED_GPU=1",
              ] + argv)
              try:
                  machine.succeed(as_user(command))
                  machine.wait_for_unit(unit, user=user)
                  # Catch immediate crashes without relying on a launcher exit code.
                  for _ in range(10):
                      machine.sleep(1)
                      # ocr isn't working for me, so this gives enough time for
                      # plugins to load
                      if name == "reaper":
                          machine.sleep(9)
                      machine.succeed(as_user("systemctl --user is-active " + unit))

              finally:
                  print(machine.execute(as_user("journalctl --user -u " + unit + " --no-pager"))[1])
                  machine.screenshot("smoke-" + name)
                  machine.execute(as_user("systemctl --user stop " + unit))
    '';
  }
else
  rec {
    config = darwinConfiguration.config;
    user = config.system.primaryUser;
    home = config.home-manager.users.${user};
    marker = activationMarker;
    packageNamed =
      name:
      lib.findFirst (
        package: lib.getName package == name
      ) (throw "Darwin smoke test: ${name} is missing from the Mac's home.packages") home.home.packages;
    apps = [
      {
        package = home.programs.librewolf.package;
        bundle = "LibreWolf.app";
        args = [
          "--no-remote"
          "about:blank"
        ];
      }
      {
        package = home.programs.zed-editor.package;
        bundle = "Zed.app";
      }
      {
        package = home.programs.ghostty.package;
        bundle = "Ghostty.app";
      }
      {
        package = packageNamed "bitwarden-desktop";
        bundle = "Bitwarden.app";
      }
      {
        package = packageNamed "reaper";
        bundle = "Reaper.app";
      }
    ];

    testScript = pkgs.writeShellScriptBin "testScript" ''
      set -euo pipefail

      if [[ "$(id -u)" == 0 ]]; then
        echo "Run testScript as the logged-in desktop user, not root." >&2
        exit 1
      fi
      if ! /bin/launchctl print "gui/$(id -u)" >/dev/null 2>&1; then
        echo "A logged-in macOS GUI session is required." >&2
        exit 1
      fi

      artifacts="''${SMOKE_ARTIFACTS_DIR:-$PWD/smoke-artifacts}"
      mkdir -p "$artifacts"

      # Activation must have configured the same account whose GUI we are using.
      [[ "$(id -un)" == ${lib.escapeShellArg user} ]]
      [[ "$(id -u)" == ${toString config.users.users.${user}.uid} ]]
      [[ "$HOME" == ${lib.escapeShellArg home.home.homeDirectory} ]]
      /usr/bin/dscl . -read /Users/${user} >"$artifacts/account.log"
      grep -Fx ${lib.escapeShellArg "NFSHomeDirectory: ${home.home.homeDirectory}"} "$artifacts/account.log"
      test -f ${lib.escapeShellArg marker}
      # A switch must install the profile consumed by activate-system on boot.
      [[ "$(cat ${lib.escapeShellArg "${config.system.profile}/systemConfig"})" -ef /run/current-system ]]

      # Verify representative Home Manager files and actual per-user preferences.
      ${lib.concatMapStringsSep "\n"
        (
          name:
          "cmp ${lib.escapeShellArg "${home.xdg.configHome}/${name}"} ${
            lib.escapeShellArg (toString home.xdg.configFile.${name}.source)
          }"
        )
        [
          "ghostty/config"
          "zed/settings.json"
        ]
      }
      [[ "$(/usr/bin/defaults read com.apple.dock orientation)" == ${lib.escapeShellArg config.system.defaults.dock.orientation} ]]
      [[ "$(/usr/bin/defaults read com.apple.finder AppleShowAllExtensions)" == ${
        if config.system.defaults.finder.AppleShowAllExtensions then "1" else "0"
      } ]]

      check_job() {
        local target="$1" mode="$2" output="$artifacts/''${1//\//_}.log"
        for _ in {1..60}; do
          if sudo -n /bin/launchctl print "$target" >"$output" 2>&1; then
            case "$mode" in
              registered) return 0 ;;
              running)
                if grep -Eq '^[[:space:]]*state = running[[:space:]]*$' "$output"; then
                  return 0
                fi
                ;;
              completed)
                # A previously successful run is not enough if the current run
                # is still executing (or waiting for launchd to start it).
                if grep -Eq '^[[:space:]]*state = (not running|exited)[[:space:]]*$' "$output"; then
                  if grep -Eq '^[[:space:]]*last exit code = 0[[:space:]]*$' "$output"; then
                    return 0
                  fi
                  if grep -Eq '^[[:space:]]*last exit code = -?[1-9][0-9]*[[:space:]]*$' "$output"; then
                    cat "$output"
                    echo "FAIL: launchd job exited unsuccessfully: $target" >&2
                    return 1
                  fi
                fi
                ;;
            esac
          fi
          sleep 1
        done
        cat "$output"
        echo "FAIL: launchd job not ready ($mode): $target" >&2
        return 1
      }

      ${lib.concatMapStringsSep "\n" (
        job:
        "check_job ${lib.escapeShellArg "system/${job.serviceConfig.Label}"} ${
          if job.serviceConfig.KeepAlive == true then
            "running"
          else if job.serviceConfig.RunAtLoad == true then
            "completed"
          else
            "registered"
        }"
      ) (lib.attrValues config.launchd.daemons)}
      ${lib.concatMapStringsSep "\n" (
        agent:
        "check_job ${agent.domain}/$(id -u)/${lib.escapeShellArg agent.config.Label} ${
          if agent.config.KeepAlive == true then
            "running"
          else if agent.config.RunAtLoad == true then
            "completed"
          else
            "registered"
        }"
      ) (lib.attrValues (lib.filterAttrs (_: agent: agent.enable) home.launchd.agents))}

      failed=0
      current_pid=""
      cleanup() {
        if [[ -n "$current_pid" ]]; then
          kill "$current_pid" 2>/dev/null || true
          for _ in {1..5}; do
            if ! kill -0 "$current_pid" 2>/dev/null; then
              break
            fi
            sleep 1
          done
          kill -KILL "$current_pid" 2>/dev/null || true
          wait "$current_pid" 2>/dev/null || true
        fi
      }
      trap cleanup EXIT
      trap 'exit 130' INT
      trap 'exit 143' TERM

      smoke() {
        local bundle="$1"
        shift
        local name executable log alive
        name="$(basename "$bundle" .app)"
        log="$artifacts/$name.log"
        echo "Testing $name"

        if ! executable=$(/usr/libexec/PlistBuddy -c 'Print :CFBundleExecutable' "$bundle/Contents/Info.plist"); then
          echo "FAIL: missing or invalid app bundle: $bundle" >&2
          failed=1
          return
        fi
        executable="$bundle/Contents/MacOS/$executable"
        if [[ ! -x "$executable" ]]; then
          echo "FAIL: executable not found: $executable" >&2
          failed=1
          return
        fi

        # Run the bundle's main executable, not a short-lived CLI launcher. As in
        # the Linux tests, verify process survival, not just a successful spawn.
        "$executable" "$@" >"$log" 2>&1 &
        current_pid=$!
        alive=1
        for _ in {1..10}; do
          sleep 1
          if ! kill -0 "$current_pid" 2>/dev/null; then
            alive=0
            break
          fi
        done

        /usr/sbin/screencapture -x "$artifacts/$name.png" 2>/dev/null || true
        if [[ "$alive" == 1 ]]; then
          echo "PASS: $name stayed running for 10 seconds"
        else
          echo "FAIL: $name exited during startup" >&2
          cat "$log"
          failed=1
        fi
        cleanup
        current_pid=""
      }

      # CLI commands should exit successfully; unlike GUI apps, they must not
      # be required to stay running. Use the activated user's installed profile.
      export PATH="$HOME/.nix-profile/bin:/etc/profiles/per-user/${user}/bin:/run/current-system/sw/bin:$PATH"
      smoke_cli() {
        local name="$1" log="$artifacts/$1-cli.log"
        echo "Testing CLI: $*"
        if "$@" >"$log" 2>&1; then
          echo "PASS: $name"
        else
          cat "$log"
          echo "FAIL: $name" >&2
          failed=1
        fi
      }
      ${lib.concatMapStringsSep "\n" (argv: "smoke_cli ${lib.escapeShellArgs argv}") cliChecks}

      ${lib.concatMapStringsSep "\n" (
        app:
        "smoke ${lib.escapeShellArg "${app.package}/Applications/${app.bundle}"} ${
          lib.escapeShellArgs (app.args or [ ])
        }"
      ) apps}
      smoke /Applications/ClickUp.app
      smoke /Applications/zoom.us.app
      exit "$failed"
    '';

    environment.systemPackages = [ testScript ];
  }
