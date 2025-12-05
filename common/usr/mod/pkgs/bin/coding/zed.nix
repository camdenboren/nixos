{
  hostname,
  lib,
  ...
}:

let
  isVM = lib.hasSuffix "vm" hostname;
in
{
  programs.zed-editor = {
    enable = true;

    extensions = [
      "nix"
      "java"
      "vue"
      "zed-legacy-themes"
    ];

    mutableUserDebug = false;
    mutableUserKeymaps = false;
    mutableUserSettings = false;
    mutableUserTasks = false;

    userSettings = {
      # basic
      auto_update = false;
      vim_mode = (hostname != "media");
      relative_line_numbers = "enabled";
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
      project_panel = {
        sticky_scroll = false;
      };

      # disable crap
      notification_panel = {
        button = false;
      };
      collaboration_panel = {
        button = false;
      };
      debugger = {
        button = false;
      };
      git_panel = {
        button = false;
      };
      outline_panel = {
        button = false;
      };
      terminal = {
        button = false;
      };
      features = {
        edit_prediction_provider = "none";
      };
      search = {
        button = false;
      };
      tab_bar = {
        show_nav_history_buttons = false;
        show_tab_bar_buttons = false;
      };
      title_bar = {
        show_sign_in = false;
      };
      toolbar = {
        breadcrumbs = false;
        quick_actions = false;
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
      agent = {
        enabled = !isVM;
        button = false;
        default_model = {
          provider = "ollama";
          model = if (hostname == "media") then "mistral:latest" else "mistral-nemo:latest";
        };
      };
      language_models = {
        ollama = {
          api_url = if (hostname == "media") then "http://192.168.1.65:11434" else "http://localhost:11434";
        };
      };
    };
  };
}
