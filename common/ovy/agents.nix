{ hostname, ... }:

let
  # media runs it in a service as a distinct user (for open-webui) so this avoids
  # permissions issues
  selfSignedCerts = hostname != "media";
in
{
  nixpkgs.overlays = [
    (_final: prev: {
      # nixpkgs is outdated
      codex-acp = prev.callPackage ../drv/codex-acp { };
      kiwix-mcp = prev.callPackage ../drv/kiwix-mcp { inherit selfSignedCerts; };
      pi-acp = prev.callPackage ../drv/pi-acp { };
      pi-mcp-adapter = prev.callPackage ../drv/pi-mcp-adapter { };
    })
  ];
}
