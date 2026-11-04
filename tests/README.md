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

Every host tests LibreWolf, Zed, Ghostty, Nautilus, and git. `main`
additionally checks REAPER. `main` and `media` also test several extra apps,
run `gh --version` as the configured user, verify the Home Manager
`ollama.service` starts, and wait for its local `/api/version` endpoint. This
checks Ollama startup without downloading models or requiring GPU inference.

`media` additionally checks nginx startup, its HTTP-to-HTTPS redirect, and
static HTTPS content at `draw.home.local`. TLS is verified against the
VM-generated minica CA. This does not require backend credentials or exercise
the full homelab.

`media` also starts the Penpot frontend container (`serviceChecks`), which
loads its image from a digest-pinned archive (see `common/drv/container-images
`) and so needs no network. These images are several GB, so the VM disks are
sized to hold them (12 GB for `media`, 32 GB for `main`). `main` does not test
InvokeAI: its check (`checks.mainci`) uses the `mainci` configuration, which
omits the module, so the image is neither built nor loaded there.

Linux VM tests enable `enableOCR` (`machine.wait_for_text`) to verify GUI
windows actually render. App checks in `tests/smoke.nix` are self-contained
records of `{ name, args ? [], ocr ? [] }`; host-specific apps use the same
shape in `appChecks` (e.g. `reaper` in `tests/hosts/main.nix`).

The test workflow runs a CI matrix job for each host, using x86 Linux runners
for `main`, `mainvm`, and `media`, and an ARM Linux runner for `macvm`.
Excepting the latter, each runner must expose `/dev/kvm`; the workflow enables
access before running the VM test. Only checks matching the selected system's
architecture are exposed.

### Test credentials

The Linux branch of `tests/smoke.nix` derives `isVM` from the host's `vm`
suffix. Shared physical-host overrides and the `tests/support/secrets.nix`
import apply only when `!isVM` (`main` and `media`); host-specific settings
remain in their test files.

`tests/support/secrets.nix` disables SOPS decryption and build-time ciphertext
validation, but retains each host's secret declarations and their consumer
paths, owners, groups, and modes. A `test-fixtures.service` installs public
fake plaintext values under `/run/secrets` before `sysinit.target` and normal
services start, and is ordered before `sysinit-reactivation.target`. Files are
recreated on each boot.

Environment-file consumers receive `NAME=value` contents; password, pepper, and
OIDC secret consumers receive raw strings, not YAML. The fixture values also
exist in the Nix store and are **not real credentials**. No production keys are
needed, and these fixtures must never be imported by a production host.

Add an explicit fixture when declaring a new secret. Early user-creation
secrets and SOPS templates are deliberately unsupported and fail evaluation.
These tests exercise services reading credentials, not SOPS decryption or
external logins.

## Darwin

Darwin follows the build/activate/testScript approach from fast-nix-gc, not a
VM test. `.github/workflows/test.yaml` runs it on an ephemeral macOS runner.
`tests/smoke.nix` contains both the Darwin shell script and Linux Python
script, selected by platform. Shared CI adaptations live in `tests/smoke.nix`;
host-specific check selection remains in the host test files.

The test configuration extends `darwinConfigurations.mac`, retaining the host's
modules, Home Manager configuration, macOS preferences, launchd services, and
Homebrew cask list except Tailscale (to keep onboarding off screenshots). It
then checks LibreWolf, Zed, Ghostty, Bitwarden, FreeTube, REAPER, ClickUp, and
Zoom, plus the built-in macOS SSH client (`/usr/bin/ssh -V`) and
credential-free CLI checks using `gam version simple` and `gh --version`.

CI-specific overrides:

- Darwin CI adaptations live in `tests/smoke.nix`; `tests/hosts/mac.nix`
  selects checks. The production Mac files are unchanged. Keep the personal
  account module enabled, overriding its user declarations with the existing
  `runner` account using the host account's UID (501) and shell. Replace the
  Home Manager user key with `runner`, importing the same Mac user modules and
  overriding only their username/home (plus the test-specific settings below).
- Preserve the runner's Nix installation. Keep nix-homebrew enabled with its
  user overridden to `runner`; skip Homebrew auto-update and disable cleanup.
  Exclude `tailscale-app` from test casks so its onboarding window does not
  obscure screenshots. Keep the host's managed `/etc/hosts`; back up the
  runner's original as `/etc/hosts.before-smoke`, not `hosts.before-nix-darwin`
  (which nix-darwin restores during networking activation).
- Keep `fetch-rs` enabled with its account, flake path, and secret owner
  adapted to `runner`. `tests/support/secrets.nix` applies the
  plaintext-fixture approach on Darwin: retain SOPS declarations and
  permissions, disable ciphertext validation and decryption, and install
  public fake tokens before launchd loads consumers. These tokens do not
  authenticate to GitHub; authenticated updates are not tested. Disable the
  scheduled repository-refresh agent. Other host services remain enabled.
- Keep the personal activation module enabled. Transform the merged
  post-activation script to refresh settings for `runner` and skip only the
  interactive screen-lock password command, preserving Home Manager activation.
  Battery and AC power settings, keyboard remapping, startup-chime settings,
  and ordinary macOS preference activation remain intact. Add hardware-specific
  overrides only if a runner failure demonstrates they are necessary.

Darwin uses the same composable `appChecks`, `cliChecks`, `serviceChecks`,
`userServiceChecks`, `checkExtra...`, and `extraChecks` arguments as Linux.
App records use `{ package, bundle, args ? [], ocr }`, or an absolute `bundle`
path without `package`. Service checks name `launchd.daemons` keys;
user-service checks name Home Manager `launchd.agents` keys. Service lists are
explicit opt-ins, never inferred from the host configuration. Both extra
service lists are empty on Darwin. Add individual jobs via `serviceChecks` and
`userServiceChecks`. `extraChecks` is shell on Darwin and Python on Linux.

Like the Linux tests, Darwin runs CLI checks, explicitly selected service
checks, optional `extraChecks`, and then app startup checks. Darwin service
checks verify launchd registration only. The script requires a logged-in GUI
session and a non-root user; it does not add account, activation-marker,
configuration-file, or macOS preference assertions. The Mac-specific
`extraChecks` verifies that `replace-configs` created the Ghostty workflow's
document and Info.plist, like Linux's one-shot output checks.

Build-only check (does **not** launch apps or install casks):

```sh
nix build .#checks.aarch64-darwin.mac
```

Activation applies the adapted Mac host configuration, including its Home
Manager files, preferences, services, and Homebrew casks except Tailscale
(requiring network access). Use `darwin-rebuild switch`, not direct `activate`,
so the system profile is installed before launchd jobs start. Do not activate
this CI configuration on your everyday Mac.

`testScript` runs as the desktop user, not under sudo. It requires a
single-display GUI session, Screen Recording permission, and installed Xcode
/Command Line Tools with a macOS SDK. The Swift helper (`tests/support
/darwin-ocr.swift`) uses on-device Apple Vision OCR.

Apps with `ocr` markers must show all markers in one frame within 60 seconds;
that exact frame becomes the screenshot. Matching ignores case and normalizes
whitespace. Unlike Linux, markers are checked together rather than
sequentially. Every app check requires nonempty `ocr` markers; there is no
skip or window-only fallback. LibreWolf checks `New Tab`; ClickUp checks
`Welcome back!`. Each launched app must stay alive and is cleaned up afterward.

Artifacts go to `./smoke-artifacts` (`SMOKE_ARTIFACTS_DIR` overrides):
`<app>.png` on success, `<app>-timeout.png` or `<app>-failure.png` when a
capture is available on failure. Timeouts print OCR diagnostics; capture/OCR
errors fail the test. CI uploads the PNGs.
