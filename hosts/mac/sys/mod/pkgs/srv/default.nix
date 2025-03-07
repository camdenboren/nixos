{ ... }:

{
  imports = [
    # Host-specific
    ./ollama.nix
  ];

  services.ollama = {
    enable = true;
  };
}
