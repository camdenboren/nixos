{ system, ... }:

let
  preset = if (system == "main") then "HF_KEG_AKG" else "Pioneer";
  extraPresets =
    if (system == "main") then
      {
        hf-kef-akg = (import ./HF_KEF_AKG.nix);
      }
    else
      {
        pioneer = (import ./Pioneer.nix);
      };
in
{
  services.easyeffects = {
    enable = true;
    inherit preset extraPresets;
  };
}
