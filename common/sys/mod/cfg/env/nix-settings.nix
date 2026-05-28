{
  inputs,
  ...
}:

{
  nix = {
    nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];
    registry.nixpkgs.flake = inputs.nixpkgs;
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];

      substituters = [
        "https://camdenboren.cachix.org"
        "https://edu-nation.cachix.org"
      ];
      trusted-public-keys = [
        "camdenboren.cachix.org-1:gjOBUYw06+i6CJIjfmVJ+ASrVLoEoOOn/2d6XcQkiFA="
        "edu-nation.cachix.org-1:S2s7ZDuLeFrV2qhfzXWNt+/XlnGxUjvUHv0WI+BvM+0="
      ];
    };
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
}
