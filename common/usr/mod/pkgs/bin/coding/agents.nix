{
  pkgs,
  lib,
  config,
  system,
  hostname,
  ...
}:

let
  jsonFormat = pkgs.formats.json { };
  isVM = lib.hasSuffix "vm" hostname;
  isDarwin = lib.hasSuffix "-darwin" system;
  mcp = import ../../../../dot/agents/mcp.nix { inherit pkgs; };
  rtkEnv = {
    RTK_TELEMETRY_DISABLED = "true";
    RTK_DB_PATH = "${config.home.homeDirectory}/rtk/history.db";
  };

  allowPaths = [
    "."
    "/tmp"
    "~/rtk"
    "${config.xdg.cacheHome}/nix"
    "~/Documents/Repos/nixpkgs"
    "~/Documents/Repos/nix-darwin"
    "~/Documents/Repos/home-manager"
  ];

  allowReadPaths = [
    ".agents/skills"
    "~/.config/git/config"
    "/nix/store"
    "~/.nix-profile"
    "/nix/var/nix/daemon-socket"
    "/nix/var/nix/profiles"
    "/etc/nix"
    "${config.xdg.configHome}/nix"
    "${config.xdg.stateHome}/nix"
    "${config.xdg.cacheHome}/nix"
  ];

  denyPaths = [
    "~/.ssh"
    "~/.config"
    "~/.local"
    "/var/lib"
    "/etc/ssh"
    "~/.bash_history"
  ]
  # no reason to directly access this since it's just media and personal data
  ++ lib.optionals (hostname == "media") [
    "/mnt/media"
    "/run/camdenboren/media/backup"
  ]
  ++ lib.optionals isDarwin [
    "/Library"
    "~/Library"
  ];

  sandbox = {
    enabled = true;

    network = {
      disabled = false;
      allowedDomains = [ "archive.home.local" ];
      allowUnixSockets = [ "/nix/var/nix/daemon-socket/socket" ];
      # above is insufficient for linux hosts
      allowAllUnixSockets = !isDarwin;
    };

    filesystem = {
      allowRead = allowPaths ++ allowReadPaths;
      denyRead = denyPaths;
      allowWrite = allowPaths;
      denyWrite = denyPaths;
    };
  };

  pi-permissions = {
    permission = {
      "*" = "allow";

      bash = {
        "*" = "allow";
        # i want this, but it confuses the heck out of qwen
        #"rm *" = "deny";
        "ssh *" = "deny";
        "gam *" = "deny";
        "sudo *" = "deny";
        "sops *" = "deny";
        "rsync *" = "deny";
        "history" = "deny";
        "history *" = "deny";
        "gh *" = "ask";
        "git *" = "ask";
        "git add" = "allow";
        "git add *" = "allow";
        "git status" = "allow";
        "git status *" = "allow";
        "git diff" = "allow";
        "git diff *" = "allow";
        "git log" = "allow";
        "git log *" = "allow";
        "git show" = "allow";
        "git show *" = "allow";
        "git branch" = "allow";
        "git branch *" = "allow";
        "git ls-files" = "allow";
        "git ls-files *" = "allow";
        "git rev-parse *" = "allow";
      };

      path = {
        "*.env" = "deny";
        "*.env.*" = "deny";
        "*.pem" = "deny";
        "*.key" = "deny";
        "*.p8" = "deny";
        "*.p12" = "deny";
        "*.pfx" = "deny";
        "*.jks" = "deny";
        "*.keystore" = "deny";
        "*credentials*" = "deny";
        "*secret*" = "deny";
        "*auth*.json" = "deny";
        "*token*" = "ask";
        "*ssh_host_*_key" = "deny";
        "*id_rsa*" = "deny";
        "*id_ed25519*" = "deny";
        "*id_ecdsa*" = "deny";
        "*service-account*" = "deny";
      };

      special = {
        doom_loop = "deny";
      };
    };
  };
in
{
  home = {
    sessionVariables = rtkEnv;

    # needed for pi + pi-sandbox
    packages =
      with pkgs;
      [
        ripgrep
        xerj-bin
        rtk
      ]
      ++ lib.optionals (!isDarwin) [
        bubblewrap
        socat
        wl-clipboard # pi
      ];

    file = {
      # creates alternate rtk dir so i don't have to manually migrate it after
      # first run; RTK_DB_PATH may not populate in shell until restarting,
      # though acp usage should work immediately
      "rtk/.init".text = "";

      # needed for pi packages + custom pi review; latter based on:
      # `opencode/packages/core/src/plugin/command/review.txt`
      ".pi/agent/prompts".source = ../../../../dot/agents/prompts;
      ".pi/agent/sandbox.json".source = jsonFormat.generate "sandbox" sandbox;
      ".pi/agent/extensions/pi-permission-system/config.json".source =
        jsonFormat.generate "pi-permissions" pi-permissions;

      # skills
      ".agents/skills".source = ../../../../dot/agents/skills;

      # mcp
      ".agents/mcp.json".source = jsonFormat.generate "mcp" mcp;
      ".pi/agent/mcp.json".source = jsonFormat.generate "mcp" mcp;
    };
  };

  programs = {
    pi-coding-agent = {
      enable = true;

      context = ''
        You’re running in a sandboxed environment with no access to external
        networks (only archive.home.local is allowed) and limited filesystem
        access—read/write is restricted to the current directory, a few repos,
        and /tmp (nix-related directories are largely read-only). Avoid
        operations like cloning repos from GitHub, installing packages from
        npm, or reading network resources; if you need to fetch content,
        suggest manual alternatives instead. Additionally, some command
        sanitation is also applied to preserve tokens.

        Default to pi-lsp for checking most file edits since targeted LSP
        diagnostics/fixes on a few edited files would be faster than a
        full-project lint/typecheck — e.g., for exact-range diagnostics or a
        source action like source.fixAll/source.organizeImports. As needed, run
        the repo's authoritative lint/typecheck/build/test commands before
        considering a task done; pi-lsp is a fast intermediate signal, not a
        replacement for CI.
      '';

      settings = {
        defaultModel = if isDarwin then "gpt-6.1-sol" else "claude-haiku-5-5";
        defaultProvider = if isDarwin then "openai-codex" else "opencode-go";
        defaultThinkingLevel = "medium";
        packages = [
          "${pkgs.pi-lsp}/lib/pi-lsp"
          "${pkgs.rtk.src}/hooks/pi/rtk.ts"
          "${pkgs.pi-sandbox}/lib/pi-sandbox/index.ts"
          "${pkgs.pi-permission-system}/lib/pi-permission-system/index.ts"
        ];
      };

      models = {
        providers = {
          ollama = {
            api = "openai-completions";
            apiKey = "ollama";
            baseUrl = "http://192.168.1.88:11434/v1";
            models = [
              {
                id = "qwen3.6:latest";
                reasoning = true;
              }
              {
                id = "gpt-oss:latest";
                reasoning = true;
              }
            ];
          };
        };
      };
    };

    zed-editor.userSettings = {
      agent = {
        enabled = !isVM;
        button = false;
        dock = "right";
        threads_sidebar.position = "right";
        default_model = {
          provider = "ollama";
          model = "qwen3.6:latest";
        };
      };

      language_models = {
        ollama = {
          api_url = "http://192.168.1.88:11434";
          available_models = [
            {
              name = "qwen3.6:latest";
              max_tokens = 131072;
              supports_tools = true;
              keep_alive = "30m";
            }
            {
              name = "gpt-oss:latest";
              max_tokens = 131072;
              supports_tools = true;
              keep_alive = "30m";
            }
          ];
        };
      };

      agent_servers = {
        Pi = {
          type = "custom";
          command = "${pkgs.pi-acp}/bin/pi-acp";
          env = rtkEnv;
        };
      };

      context_servers = {
        kiwix-mcp =
          # avoids conflicting w/ media's service used by open-webui
          if (hostname != "media") then
            {
              command = "${pkgs.kiwix-mcp}/bin/kiwix-mcp";
              env.KIWIX_BASE_URL = "https://archive.home.local";
            }
          else
            {
              url = "http://localhost:8000/mcp";
            };
        xerj = lib.mkIf (!isVM) {
          command = "${pkgs.xerj-bin}/bin/xerj";
          args = [ "mcp" ];
        };
      };
    };
  };
}
