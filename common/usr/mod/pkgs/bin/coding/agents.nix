{
  pkgs,
  lib,
  system,
  hostname,
  ...
}:

let
  isVM = lib.hasSuffix "vm" hostname;
  isDarwin = lib.hasSuffix "-darwin" system;
in
{
  programs = {
    codex = {
      enable = isDarwin;
      package = pkgs.codex.overrideAttrs rec {
        pname = "codex";
        version = "0.154.0";
        src = pkgs.fetchFromGitHub {
          owner = "openai";
          repo = "codex";
          tag = "rust-v${version}";
          hash = "sha256-Nm+61N6YHxGhjLsm/giVSEg4QvJmIgWxyTQ1L89kpCs=";
        };
        sourceRoot = "${src.name}/codex-rs";
        cargoHash = "sha256-9F8dyEiVkhelrIyfQ9ZkvuxfIYNN6akbpadREa4A1n0=";
        cargoDeps = pkgs.rustPlatform.fetchCargoVendor {
          inherit src sourceRoot;
          hash = cargoHash;
        };
      };
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
      context = ../../../../dot/agents/skills;
      settings = {
        defaultModel = "qwen3.6:latest";
        defaultProvider = "ollama";
        packages = [
          "${pkgs.pi-mcp-adapter}/lib/node_modules/pi-mcp-adapter"
        ];
      };
      models = {
        providers = {
          ollama = {
            api = "openai-completions";
            apiKey = "ollama";
            baseUrl = "http://192.168.1.88:11434/v1";
            models = [
              { id = "qwen3.6:latest"; }
              { id = "gpt-oss:latest"; }
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
        sidebar_side = "right";
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
              keep_alive = "5m";
            }
            {
              name = "gpt-oss:latest";
              max_tokens = 65536;
              supports_tools = true;
              keep_alive = "5m";
            }
          ];
        };
      };

      agent_servers = {
        Codex = lib.mkIf isDarwin {
          type = "custom";
          command = "${pkgs.codex-acp}/bin/codex-acp";
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
