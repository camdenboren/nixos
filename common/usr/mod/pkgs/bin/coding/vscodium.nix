{
  pkgs,
  lib,
  hostname,
  ...
}:

{
  programs.vscode = {
    enable = true;
    mutableExtensionsDir = false;
    package = pkgs.vscodium;
    userSettings = {
      # Styling
      "workbench" = {
        "enableExperiments" = false;
        "externalBrowser" = "librewolf";
        "editorAssociations" = {
          "*.md" = "vscode.markdown.preview.editor";
        };
        "startupEditor" = "none";
      };
      "window" = {
        "newWindowDimensions" = "maximized";
        "zoomLevel" = if (hostname == "mac") then 0.25 else 1;
      };

      # Functionality
      "editor.wordWrap" = "on";
      "files.autoSave" = "afterDelay";
      "update.mode" = "none";

      # Nix Support
      "nix" = {
        "enableLanguageServer" = true;
        "serverPath" = "nixd";
      };
      "nix.hiddenLanguageServerErrors" = [
        "textDocument/definition"
      ];
      "nix.serverSettings.nixd" = {
        "nixpkgs" = {
          "expr" = "import <nixpkgs> { }";
        };
        "formatting" = {
          "command" = "nixfmt";
        };
      };

      # Git Integration
      "git" = {
        "autofetch" = false;
        "confirmSync" = false;
      };

      # Extensions and Telemetry
      "extensions" = {
        "autoUpdate" = false;
        "autoCheckUpdates" = false;
        "ignoreRecommendations" = true;
      };
      "continue" = {
        "enableTabAutocomplete" = false;
        "showInlineTip" = false;
        "telemetryEnabled" = false;
      };
      "java.jdt.ls.androidSupport.enabled" = "on";
      "java.configuration.updateBuildConfiguration" = "disabled";
      "java.format.settings.url" =
        "https://raw.githubusercontent.com/google/styleguide/gh-pages/eclipse-java-google-style.xml";
      "java.server.launchMode" = "LightWeight";
      "gradle.reuseTerminals" = "all";
      "redhat.telemetry.enabled" = false;
      "sonarlint.disableTelemetry" = true;
      "python.testing.unittestEnabled" = true;
      "telemetry" = {
        "enableTelemetry" = false;
        "enableCrashReporter" = false;
        "telemetryLevel" = "off";
      };
      "code-runner.enableAppInsights" = false;
    };
    extensions =
      with pkgs.vscode-extensions;
      [
        ms-vscode.remote-repositories
        github.remotehub
      ]
      ++ lib.optionals (hostname == "mac") [
        redhat.java
        vscjava.vscode-java-debug
        sonarsource.sonarlint-vscode
        ms-vscode.live-server
        vscjava.vscode-gradle
      ];
  };
}
