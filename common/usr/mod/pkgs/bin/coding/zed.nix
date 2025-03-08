{
  hostname,
  lib,
  ...
}:

let
  isVM = lib.hasSuffix "-vm" hostname;
in
{
  programs.zed-editor = {
    enable = true;

    extensions = [
      "nix"
      "java"
      "ruff"
      "vue"
      "zed-legacy-themes"
    ];

    userSettings = {
      # basic
      auto_update = false;
      vim_mode = true;
      soft_wrap = "editor_width";
      autosave = {
        after_delay = {
          milliseconds = 500;
        };
      };
      tabs = {
        git_status = true;
      };
      max_tabs = 10;

      # disable crap
      notification_panel = {
        button = false;
      };
      chat_panel = {
        button = "never";
      };
      collaboration_panel = {
        button = false;
      };
      outline_panel = {
        button = false;
      };
      terminal = {
        button = false;
      };
      features = {
        copilot = false;
        edit_completion_provider = "none";
      };
      telemetry = {
        diagnostics = false;
        metrics = false;
      };

      # language configs
      languages = {
        "Nix" = {
          language_servers = [
            "nixd"
            "!nil"
          ];
        };
        Python = {
          language_servers = [
            "pyright"
            "ruff"
          ];
          tasks = {
            variables = {
              TEST_RUNNER = "unittest";
            };
          };
        };
      };
      lsp = {
        pyright = {
          settings = {
            python.analysis = {
              diagnosticMode = "workspace";
            };
          };
        };
      };

      # ollama settings
      assistant = {
        enabled = !isVM;
        default_model = {
          provider = "ollama";
          model = if (hostname == "media") then "tinydolphin:latest" else "mistral-nemo:latest";
        };
        version = "2";
      };
    };
  };
}
