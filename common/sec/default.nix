{
  inputs,
  lib,
  hostname,
  system,
  ...
}:

let
  isDarwin = lib.hasSuffix "-darwin" system;
  shared = {
    fetch-rs = { };
    nut = {
      key = "password";
      restartUnits = [
        "upsd.service"
        "upsmon.service"
      ];
    };
    vector.restartUnits = [ "vector.service" ];
  };
  secrets =
    {
      main = shared;
      media = shared // {
        backup = { };
        # Outline reads this directly; Dex's privileged setup can also read it.
        dex = {
          key = "client_secret";
          owner = "outline";
          restartUnits = [
            "dex.service"
            "outline.service"
          ];
        };
        homebox = {
          key = "pepper";
          restartUnits = [ "homebox.service" ];
        };
        omdb-lookup.restartUnits = [ "omdb-lookup.service" ];
        openobserve.restartUnits = [ "openobserve.service" ];
        penpot.restartUnits = [
          "podman-penpot-penpot-backend.service"
          "podman-penpot-penpot-exporter.service"
        ];
        tailscale.key = "auth_key";
      };
      # The macOS wrapper sources the file as this user.
      mac.fetch-rs.owner = "camdenboren";
    }
    .${hostname};
in
{
  imports = [
    (if isDarwin then inputs.sops-nix.darwinModules.sops else inputs.sops-nix.nixosModules.sops)
  ];

  sops = {
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
    gnupg.sshKeyPaths = [ ];

    secrets = lib.mapAttrs (
      name: settings:
      {
        sopsFile = ./. + "/${name}.yaml";
        key = "environment";
      }
      # most services currently leverage the `environment` key, though this
      # overrides it w/ specific attrs specified above
      // settings
    ) secrets;
  };
}
