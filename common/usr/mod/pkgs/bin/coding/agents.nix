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
  ];
  denyPaths = [
    "~/.ssh"
    "~/.config"
    "/var/lib"
    "/etc/ssh"
    ".env"
  ]
  # no reason to directly access this since it's just media and personal data
  ++ lib.optionals (hostname == "media") [
    "/mnt/media"
    "/run/camdenboren/media/backup"
  ];
  piSandboxConfig = {
    enabled = true;

    network = {
      disabled = false;
      allowedDomains = [
        "*.home.local"
      ];
    };

    filesystem = {
      allowRead = allowPaths;
      denyRead = denyPaths;
      allowWrite = allowPaths;
      denyWrite = denyPaths;
    };
  };
in
{
  # needed for pi + pi-sandbox
  home.packages =
    with pkgs;
    [
      ripgrep
    ]
    ++ lib.optionals (!isDarwin) [
      bubblewrap
      socat
      wl-clipboard # pi
    ];

  # needed for pi-sandbox + custom pi review; based on:
  # `opencode/packages/core/src/plugin/command/review.txt`
  home.file = {
    ".pi/agent/prompts".source = ../../../../dot/agents/prompts;

    ".pi/agent/sandbox.json".text = builtins.toJSON piSandboxConfig;

    ".agents/skills" = {
      source = ../../../../dot/agents/skills;
    };

    ".codex/skills" = lib.mkIf isDarwin {
      source = ../../../../dot/agents/skills;
    };

    ".agents/mcp.json" = {
      source = jsonFormat.generate "mcp" mcp;
    };

    ".pi/agent/mcp.json" = {
      source = jsonFormat.generate "mcp" mcp;
    };
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
        mcp_servers.kiwix-mcp = {
          command = "${pkgs.kiwix-mcp}/bin/kiwix-mcp";
          env.KIWIX_BASE_URL = "https://archive.home.local";
          tools = {
            kiwix_list_books.approval_mode = "approve";
            kiwix_search.approval_mode = "approve";
            kiwix_fetch_article.approval_mode = "approve";
          };
        };
      };
    };

    opencode = {
      enable = true;
      skills = ../../../../dot/agents/skills;
      settings = {
        mcp.kiwix-mcp.enabled = true;
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
        —read/write is restricted to the current directory and /tmp (/nix/store
        is read-only). Avoid operations like cloning repos from GitHub,
        installing packages from npm, or reading network resources; if you need
        to fetch content, suggest manual alternatives instead.

        Default to pi-lsp for checking most file edits since targeted LSP
        diagnostics/fixes on a few edited files would be faster than a
        full-project lint/typecheck — e.g., for exact-range diagnostics or a
        source action like source.fixAll/source.organizeImports. As needed, run
        the repo's authoritative lint/typecheck/build/test commands before
        considering a task done; pi-lsp is a fast intermediate signal, not a
        replacement for CI.
      '';

      settings = {
        defaultModel = "qwen3.6:latest";
        defaultProvider = "ollama";
        defaultThinkingLevel = "medium";
        packages = [
          "${pkgs.pi-lsp}/lib/pi-lsp"
          "${pkgs.pi-sandbox}/lib/pi-sandbox/index.ts"
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
      };
    };
  };
}
