{ ... }:

{
  imports = [
    # Host-specific
    ./nix-daemon.nix
    ./ollama.nix
  ];

  services.ollama = {
    enable = true;
  };
}
