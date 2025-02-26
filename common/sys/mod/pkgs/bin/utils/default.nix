{ pkgs, ... }:

{
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    (nh.overrideAttrs (
      final: prev: rec {
        version = "4.0.0-beta.9";
        src = fetchFromGitHub {
          owner = "viperML";
          repo = "nh";
          tag = "v${version}";
          hash = "sha256-HcNEFumdZ4Y59CBB1h1IzOyPxwn0u/Wson6hhzItXCA=";
        };

        preFixup = '''';

        cargoDeps = prev.cargoDeps.overrideAttrs {
          name = "nh-vendor.tar.gz";
          inherit (final) src;
          outputHash = "sha256-tcT/miROl+unG8V9RklXvmOAQ9pe9QeLinicnJjcxwg=";
        };
      }
    ))
  ];
}
