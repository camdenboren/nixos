_:

{
  nixpkgs.overlays = [
    (_final: prev: {
      # not in nixpkgs
      actual-cli = prev.callPackage ../drv/actual-cli { };
      drawio = prev.callPackage ../drv/drawio { };
      outline-export = prev.callPackage ../drv/outline-export { };

      # upstream sets makeWrapperArgs as a single string, which the python
      # wrap hook no longer word-splits; makeWrapper then dies on
      # "--set FRONTEND_BUILD_DIR ..." being passed as one arg
      open-webui = prev.open-webui.overrideAttrs (o: {
        makeWrapperArgs = [
          "--set"
          "FRONTEND_BUILD_DIR"
          "${o.passthru.frontend}/share/open-webui"
        ];
      });
    })
  ];
}
