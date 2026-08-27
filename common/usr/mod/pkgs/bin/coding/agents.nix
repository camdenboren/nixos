{
  pkgs,
  lib,
  system,
  ...
}:

let
  isDarwin = lib.hasSuffix "-darwin" system;
in
{
  home.packages =
    with pkgs;
    lib.optionals isDarwin [
      # enables usage w/in zed via acp
      codex-acp
      # enables usage w/in opencode while I wait on the below issue
      kiwix-mcp
    ];

  programs = {
    codex = {
      enable = isDarwin;
      # waiting on
      # https://github.com/nix-community/home-manager/issues/9397
      /*
        settings = {
        model_reasoning_effort = "xhigh";
        // [mcp_servers.kiwix-mcp]
        // command = "${pkgs.kiwix-mcp}/bin/kiwix-mcp"
        // [mcp_servers.kiwix-mcp.env]
        // KIWIX_BASE_URL = "https://archive.home.local"
        };
      */
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
  };
}
