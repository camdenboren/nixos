{
  inputs,
  ...
}:

{
  # Set nix path
  nix.nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];

  # Pin nixpkgs registry ref to flake input
  nix.registry.nixpkgs.flake = inputs.nixpkgs;

  # Enable flakes
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];

    substituters = [ "https://cache.garnix.io" ];
    trusted-public-keys = [ "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g=" ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
}
