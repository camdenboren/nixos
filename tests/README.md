# Tests

## Linux

Run the host's VM test on a Linux runner with KVM access:

```sh
nix build .#checks.x86_64-linux.main
nix build .#checks.x86_64-linux.mainvm
nix build .#checks.x86_64-linux.media
# On ARM Linux:
nix build .#checks.aarch64-linux.macvm
```

Every host tests LibreWolf, Zed, Ghostty, and Bitwarden. `main` additionally
checks REAPER and Steam; `media` additionally checks Steam. `main` and `media`
also run `gh --version` as the configured user.

`media` additionally checks nginx startup, its HTTP-to-HTTPS redirect, and static
HTTPS content at `draw.home.local`. TLS is verified against the VM-generated
minica CA. This does not require backend credentials or exercise the full homelab.

The test workflow runs a CI matrix job for each host, using x86 Linux runners
for `main`, `mainvm`, and `media`, and an ARM Linux runner for `macvm`. Each runner
must expose `/dev/kvm`; the workflow enables access before running the VM test.
Only checks matching the selected system's architecture are exposed.

## Darwin

Darwin follows the build/activate/testScript approach from fast-nix-gc, not a
VM test. `.github/workflows/test.yaml` runs it on an ephemeral macOS runner.
`tests/smoke.nix` contains both the Darwin shell script and Linux Python script,
selected with `isDarwin`; host-specific setup remains in the host test files.

The test configuration extends `darwinConfigurations.mac`, retaining the host's
modules, Home Manager configuration, macOS preferences, launchd services, and
full Homebrew cask list. It then checks LibreWolf, Zed, Ghostty, Bitwarden,
REAPER, ClickUp, and Zoom, plus credential-free CLI checks using
`gam version simple` and `gh --version`.

CI-specific overrides:

- All adaptations live in `tests/mac.nix`; the production Mac files are unchanged.
  Exclude the personal account module and configure the existing `runner`
  account using the host account's UID (501) and shell. Replace the Home Manager
  user key with `runner`, importing the same Mac user modules and overriding
  only their username/home (plus the test-specific settings below).
- Preserve the runner's Nix and Homebrew installations, skip Homebrew auto-update,
  and disable Homebrew cleanup.
- Disable secret-dependent `fetch-rs` and SOPS secrets, and the scheduled
  repository-refresh agent. Other host services remain enabled.
- Exclude the personal activation module, which hardcodes `camdenboren`, prompts
  for the screen-lock password, and changes battery settings. Retain its safe
  settings refresh for `runner`, merged with Home Manager activation. Also skip
  power changes, keyboard hardware remapping, and startup-chime firmware writes.
  Ordinary macOS preference activation remains intact.

Before launching apps, `testScript` checks the account/home/UID, a Home Manager
activation marker, the generated Ghostty and Zed configuration files, Dock and
Finder preferences, the installed system profile, and registration of configured
system daemons and enabled Home Manager agents. KeepAlive=true jobs must reach
the running state; startup one-shots must complete with exit code zero.
Scheduled and on-demand jobs are checked for registration only.
This does not prove that every preference or service feature is correct.

Build-only check (does **not** launch apps or install casks):

```sh
nix build .#checks.aarch64-darwin.mac
```

On a **disposable ARM macOS runner**, with a logged-in GUI session for `runner`,
Homebrew, Nix, and passwordless sudo:

```sh
nix build .#darwinConfigurations.ci.system --out-link result-ci
for file in /etc/hosts /etc/bashrc /etc/zshrc /etc/zshenv /etc/bash.bashrc; do
  if [[ -e "$file" ]]; then
    sudo mv "$file" "$file.before-nix-darwin"
  fi
done
sudo env PATH="$PATH" ./result-ci/sw/bin/darwin-rebuild switch --flake .#ci
/run/current-system/sw/bin/testScript
```

Activation applies the adapted Mac host configuration, including its Home
Manager files, preferences, services, and all configured Homebrew casks
(requiring network access). Use `darwin-rebuild switch`, not direct `activate`,
so the system profile is installed before launchd jobs start. Do not activate
this CI configuration on your everyday Mac.

`testScript` must run as the desktop user, not under sudo. It launches each app's
main bundle executable, checks that it stays running for ten seconds, and stops
it before testing the next app. The app checks verify startup, not window
contents, app login, or online functionality. Logs and best-effort screenshots go to
`./smoke-artifacts` (override with `SMOKE_ARTIFACTS_DIR`); CI uploads that directory.
