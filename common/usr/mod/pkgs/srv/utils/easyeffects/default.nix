{ hostname, ... }:

let
  preset = if (hostname == "main") then "HF_KEF_AKG" else "Pioneer";
  extraPresets =
    if (hostname == "main") then
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
