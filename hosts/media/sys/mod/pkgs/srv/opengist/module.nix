{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.opengist;

  # Values set through typed options win over the free-form `settings`.
  settings = {
    # journald already captures stdout, so don't also write a log file
    "log-output" = "stdout";
    # the HTTP remote is sufficient; don't bind an extra SSH server on 2222
    "ssh.git-enabled" = "disabled";
  }
  // cfg.settings
  // {
    "opengist-home" = cfg.stateDir;
    "http.host" = cfg.listenAddress;
    "http.port" = toString cfg.port;
  }
  // lib.optionalAttrs (cfg.externalUrl != null) {
    "external-url" = cfg.externalUrl;
  };

  configFile = (pkgs.formats.yaml { }).generate "opengist.yml" settings;
in
{
  options.services.opengist = {
    enable = lib.mkEnableOption "Opengist, a self-hosted pastebin powered by Git";

    package = lib.mkPackageOption pkgs "opengist" { };

    stateDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/opengist";
      example = "/mnt/media/opengist";
      description = ''
        Directory holding Opengist's SQLite database, Git repositories, and
        generated session secret. The service user owns this directory.
      '';
    };

    listenAddress = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1";
      example = "0.0.0.0";
      description = "Address on which the HTTP server listens (sets `http.host`).";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 6157;
      description = "Port on which the HTTP server listens (sets `http.port`).";
    };

    externalUrl = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "https://gist.example.com";
      description = ''
        Public URL used to build clone URLs and links. Omit it to derive the
        URL from each request; set it when running behind a reverse proxy.
      '';
    };

    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to open the firewall for {option}`services.opengist.port`.";
    };

    environmentFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      example = "/run/secrets/opengist.env";
      description = ''
        Environment file (see {manpage}`systemd.exec(5)`) passed to the service.
        Use this for secrets such as `OG_GITHUB_SECRET` or `OG_OIDC_SECRET`
        instead of putting them into the world-readable Nix store.
      '';
    };

    settings = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.oneOf [
          lib.types.bool
          lib.types.int
          lib.types.str
          (lib.types.listOf lib.types.str)
          (lib.types.listOf (lib.types.attrsOf lib.types.str))
        ]
      );
      default = { };
      example = lib.literalExpression ''
        {
          "log-level" = "info";
          "custom.name" = "Gist";
          "search.default" = "content,title";
        }
      '';
      description = ''
        YAML configuration for Opengist, using the dotted keys from the
        upstream cheat sheet. See
        <https://github.com/thomiceli/opengist/blob/master/docs/configuration/cheat-sheet.md>.
        Do not put secrets here; use {option}`services.opengist.environmentFile`.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = lib.hasPrefix "/" cfg.stateDir;
        message = "services.opengist.stateDir must be an absolute path.";
      }
    ];

    users.users.opengist = {
      isSystemUser = true;
      group = "opengist";
      home = cfg.stateDir;
    };
    users.groups.opengist = { };

    systemd.tmpfiles.rules = [
      "d ${cfg.stateDir} 0750 opengist opengist -"
    ];

    systemd.services.opengist = {
      description = "Opengist, a self-hosted pastebin powered by Git";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];

      # Opengist shells out to git for repository operations
      path = [
        pkgs.git
        pkgs.openssh
      ];

      environment = {
        HOME = cfg.stateDir;
        OG_OPENGIST_HOME = cfg.stateDir;
      };

      serviceConfig = {
        Type = "simple";
        User = "opengist";
        Group = "opengist";
        WorkingDirectory = cfg.stateDir;
        ExecStart = "${lib.getExe cfg.package} --config ${configFile}";
        EnvironmentFile = lib.mkIf (cfg.environmentFile != null) [ cfg.environmentFile ];
        Restart = "on-failure";
        RestartSec = 5;
        NoNewPrivileges = true;
        PrivateTmp = true;
        ProtectHome = true;
        ProtectSystem = "strict";
        ReadWritePaths = [ cfg.stateDir ];
        UMask = "0027";
      };
    };

    networking.firewall = lib.mkIf cfg.openFirewall {
      allowedTCPPorts = [ cfg.port ];
    };
  };
}
