{ ... }:

{
  home.file = {
    # Set pipewire sample rate, default quantum
    ".config/pipewire/" = {
      source = ../../../dot/pipewire;
    };

    # Set default eq preset for easyeffects
    # in order: HFControlL, HFControlR, KEF, Bass, AKG
    ".config/easyeffects/" = {
      source = ../../../dot/easyeffects;
    };

    # REAPER - most settings set in replaceConfigs (and activ.)
    ".config/REAPER/Effects/jsfx" = {
      source = ../../../dot/reaper/jsfx;
    };

    ".config/REAPER/reaper-kb.ini" = {
      source = ../../../dot/reaper/reaper-kb.ini;
    };

    ".config/REAPER/presets/lv2-http___github_com_mikeoliphant_neural-amp-modeler-lv2.ini" = {
      source = ../../../dot/reaper/lv2-http___github_com_mikeoliphant_neural-amp-modeler-lv2.ini;
    };

    ".config/REAPER/Data/ix_keymaps/01_x42_Mapping.txt" = {
      source = ../../../dot/reaper/01_x42_Mapping.txt;
    };
  };
}
