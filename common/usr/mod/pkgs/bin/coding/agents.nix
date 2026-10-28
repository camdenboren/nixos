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

  allowPaths = [
    "."
    "/tmp"
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
      allowedDomains = [ "*.home.local" ];
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
        "sudo *" = "deny";
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
  # needed for pi + pi-sandbox
  home.packages =
    with pkgs;
    [
      ripgrep
      xerj-bin
    ]
    ++ lib.optionals (!isDarwin) [
      bubblewrap
      socat
      wl-clipboard # pi
    ];

  home.file = {
    # needed for pi packages + custom pi review; latter based on:
    # `opencode/packages/core/src/plugin/command/review.txt`
    ".pi/agent/prompts".source = ../../../../dot/agents/prompts;
    ".pi/agent/sandbox.json".source = jsonFormat.generate "sandbox" sandbox;
    ".pi/agent/extensions/pi-permission-system/config.json".source =
      jsonFormat.generate "pi-permissions" pi-permissions;

    # skills
    ".agents/skills".source = ../../../../dot/agents/skills;
    ".codex/skills" = lib.mkIf isDarwin { source = ../../../../dot/agents/skills; };

    # mcp
    ".agents/mcp.json".source = jsonFormat.generate "mcp" mcp;
    ".pi/agent/mcp.json".source = jsonFormat.generate "mcp" mcp;
  };

  programs = {
    codex = {
      enable = isDarwin;

      # This breaks CLI usage due to
      # https://github.com/nix-community/home-manager/issues/9397
      # BUT, I primarily use it via ACP so I instead just bank on Zed's SANE
      # approach of separating state from configuration (OpenAI has CLEARLY
      # hit AGI...)
      settings = {
        model_reasoning_effort = "medium";
        mcp_servers = {
          kiwix-mcp = {
            command = "${pkgs.kiwix-mcp}/bin/kiwix-mcp";
            env.KIWIX_BASE_URL = "https://archive.home.local";
            tools = {
              kiwix_list_books.approval_mode = "approve";
              kiwix_search.approval_mode = "approve";
              kiwix_fetch_article.approval_mode = "approve";
            };
          };
          xerj = {
            command = "${pkgs.xerj-bin}/bin/xerj";
            args = [ "mcp" ];
            tools = {
              xerj_map.approval_mode = "approve";
              xerj_search.approval_mode = "approve";
              xerj_def.approval_mode = "approve";
            };
          };
        };
      };
    };

    opencode = {
      enable = true;
      skills = ../../../../dot/agents/skills;
      tui.theme = "system";
      settings = {
        mcp = {
          kiwix-mcp = {
            enabled = true;
            type = if (hostname == "media") then "remote" else "local";
            command = lib.mkIf (hostname != "media") [ "${pkgs.kiwix-mcp}/bin/kiwix-mcp" ];
            environment.KIWIX_BASE_URL = lib.mkIf (hostname != "media") "https://archive.home.local";
            url = lib.mkIf (hostname == "media") "http://localhost:8000/mcp";
          };
          xerj = {
            enabled = !isVM;
            type = "local";
            command = [
              "${pkgs.xerj-bin}/bin/xerj"
              "mcp"
            ];
          };
        };
        model = "ollama/qwen3.6";
        permission = {
          webfetch = "deny";
          websearch = "deny";
        };
        provider.ollama = {
          npm = "@ai-sdk/openai-compatible";
          name = "Ollama";
          options = {
            baseURL = "http://192.168.1.88:11434/v1";
          };
          models = {
            "qwen3.6:latest".name = "qwen3.6";
            "gpt-oss:latest".name = "gpt-oss";
          };
        };
      };
    };

    pi-coding-agent = {
      enable = true;

      context = ''
        You’re running in a sandboxed environment with no access to external
        networks (only *.home.local is allowed) and limited filesystem access
        —read/write is restricted to the current directory, a few repos, and
        /tmp (nix-related directories are largely read-only). Avoid operations like
        cloning repos from GitHub, installing packages from npm, or reading network
        resources; if you need to fetch content, suggest manual alternatives instead.

        Default to pi-lsp for checking most file edits since targeted LSP
        diagnostics/fixes on a few edited files would be faster than a
        full-project lint/typecheck — e.g., for exact-range diagnostics or a
        source action like source.fixAll/source.organizeImports. As needed, run
        the repo's authoritative lint/typecheck/build/test commands before
        considering a task done; pi-lsp is a fast intermediate signal, not a
        replacement for CI.
      '';

      settings = {
        defaultModel = if isDarwin then "gpt-6.1-sol" else "qwen3.6:latest";
        defaultProvider = if isDarwin then "openai-codex" else "ollama";
        defaultThinkingLevel = "medium";
        packages = [
          "${pkgs.pi-lsp}/lib/pi-lsp"
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
              max_tokens = 262144;
              supports_tools = true;
              keep_alive = "30m";
            }
            {
              name = "gpt-oss:latest";
              max_tokens = 65536;
              supports_tools = true;
              keep_alive = "30m";
            }
          ];
        };
      };

      agent_servers = {
        Codex = lib.mkIf isDarwin {
          type = "custom";
          command = "${pkgs.codex-acp}/bin/codex-acp";
          env.CODEX_PATH = lib.getExe config.programs.codex.package;
        };
        OpenCode = {
          type = "custom";
          command = "${pkgs.opencode}/bin/opencode";
          args = [ "acp" ];
        };
        Pi = {
          type = "custom";
          command = "${pkgs.pi-acp}/bin/pi-acp";
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
