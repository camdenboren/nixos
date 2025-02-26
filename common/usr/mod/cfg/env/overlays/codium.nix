{ ... }:

{
  nixpkgs.overlays = [
    (
      final: prev:
      let
        buildVscodeMarketplaceExtension = final.vscode-utils.buildVscodeMarketplaceExtension;
      in
      {
        vscode-extensions = prev.vscode-extensions // {
          jnoortheen.nix-ide = (
            prev.callPackage ../../../../drv/nix-ide { inherit buildVscodeMarketplaceExtension; }
          );

          github.remotehub = (
            prev.callPackage ../../../../drv/remotehub { inherit buildVscodeMarketplaceExtension; }
          );

          ms-vscode = prev.vscode-extensions.ms-vscode // {
            remote-repositories = (
              prev.callPackage ../../../../drv/remote-repositories { inherit buildVscodeMarketplaceExtension; }
            );
          };

          vscjava = prev.vscode-extensions.vscjava // {
            vscode-gradle = (
              prev.callPackage ../../../../drv/vscode-gradle { inherit buildVscodeMarketplaceExtension; }
            );
          };
        };
      }
    )
  ];
}
