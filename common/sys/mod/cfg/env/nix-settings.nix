{
  inputs,
  ...
}:

{
  # Set nix path
  nix.nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];

  # Enable flakes
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
}
