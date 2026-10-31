# SPDX-FileCopyrightText: Camden Boren
# SPDX-License-Identifier: GPL-3.0-or-later

# fake plaintext secrets for VM tests; SOPS declarations still define consumer
# paths, ownership, and modes, but no decryption or production keys are involved
{
  config,
  lib,
  pkgs,
  ...
}:

let
  fixtures = {
    fetch-rs = ''
      GITHUB_TOKEN=smoke-test-only
      GH_TOKEN=smoke-test-only
    '';
    nut = "smoke-test-only-password\n";
    vector = ''
      VECTOR_DANGEROUSLY_ALLOW_ENV_VAR_INTERPOLATION=true
      OPENOBSERVE_USER=smoke@example.invalid
      OPENOBSERVE_PASSWORD=Smoke-test-only-password-123!
    '';
    backup = ''
      NTFY_TOPIC=smoke-test-only
      OUTLINE_API_TOKEN=smoke-test-only
      ACTUAL_PASSWORD=smoke-test-only
      ACTUAL_SYNC_ID=00000000-0000-0000-0000-000000000000
    '';
    omdb-lookup = ''
      API_KEY=abcdefghi
    '';
    openobserve = ''
      ZO_ROOT_USER_EMAIL=smoke@example.invalid
      ZO_ROOT_USER_PASSWORD=Smoke-test-only-password-123!
    '';
    homebox = "0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef\n";
    penpot = ''
      PENPOT_SECRET_KEY=0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef
    '';
    dex = "smoke-test-only-oidc-client-secret\n";
    tailscale = "tskey-auth-smoke-test-only-not-valid\n";
  };
  declared = config.sops.secrets;
  installFixture =
    name: secret:
    let
      source = pkgs.writeText "smoke-fixture-${name}" (
        fixtures.${name} or (throw "Missing plaintext test fixture for SOPS secret ${name}")
      );
      owner = if secret.owner != null then secret.owner else toString secret.uid;
      group = if secret.group != null then secret.group else toString secret.gid;
    in
    ''
      install -D -m ${lib.escapeShellArg secret.mode} \
        -o ${lib.escapeShellArg owner} -g ${lib.escapeShellArg group} \
        ${lib.escapeShellArg (toString source)} ${lib.escapeShellArg secret.path}
    '';
in
{
  assertions = [
    {
      assertion = lib.all (secret: !secret.neededForUsers && lib.hasPrefix "/run/" secret.path) (
        lib.attrValues declared
      );
      message = "VM fixtures only support runtime secrets under /run, not neededForUsers secrets.";
    }
    {
      assertion = config.sops.templates == { };
      message = "VM plaintext fixtures do not render SOPS templates; add explicit test fixtures for them.";
    }
  ];

  sops.validateSopsFiles = lib.mkForce false;
  sops.age.generateKey = lib.mkForce false;
  system.activationScripts.setupSecrets.text = lib.mkForce "";
  systemd.services.sops-install-secrets.enable = lib.mkForce false;

  systemd.services.test-fixtures = {
    description = "Install public fake credentials for VM smoke tests";
    wantedBy = [ "sysinit.target" ];
    requiredBy = [
      "sysinit.target"
      "sysinit-reactivation.target"
    ];
    before = [
      "sysinit.target"
      "sysinit-reactivation.target"
    ];
    after = [
      "local-fs.target"
      "systemd-sysusers.service"
      "userborn.service"
    ];
    unitConfig.DefaultDependencies = false;
    path = [ pkgs.coreutils ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      set -euo pipefail
      install -d -m 0751 -o root -g root /run/secrets
      ${lib.concatStringsSep "\n" (lib.mapAttrsToList installFixture declared)}
    '';
  };
}
