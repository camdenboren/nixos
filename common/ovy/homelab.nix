_:

{
  nixpkgs.overlays = [
    (_final: prev: {
      # not in nixpkgs
      actual-cli = prev.callPackage ../drv/actual-cli { };
      drawio = prev.callPackage ../drv/drawio { };
      omdb-lookup = prev.callPackage ../drv/omdb-lookup { };
      outline-export = prev.callPackage ../drv/outline-export { };
      workerd = prev.callPackage ../drv/workerd { };
      container-images = prev.callPackage ../drv/container-images { };

      # nixpkgs trails upstream; pin the release the homelab runs. The frontend
      # is embedded in the Go binary, so it needs the same source and a
      # refreshed npm dependency hash alongside `vendorHash`. The release also
      # requires a newer Go than the default `buildGoModule` provides.
      opengist = (prev.opengist.override { buildGoModule = prev.buildGoLatestModule; }).overrideAttrs (
        finalAttrs: _: {
          version = "1.15.3";

          src = prev.fetchFromGitHub {
            owner = "thomiceli";
            repo = "opengist";
            tag = "v${finalAttrs.version}";
            hash = "sha256-tDmWv3Tsfgskn94RGrREBLyOJir2+OuCo7M7qXSOcZ8=";
          };

          frontend = prev.buildNpmPackage {
            pname = "opengist-frontend";
            inherit (finalAttrs) version src;

            # npm complains about the missing version in package.json
            postPatch = ''
              ${prev.lib.getExe prev.jq} '.version = "${finalAttrs.version}"' package.json \
                | ${prev.lib.getExe' prev.moreutils "sponge"} package.json
            '';

            installPhase = ''
              mkdir -p $out
              cp -R public $out
            '';

            npmDepsHash = "sha256-9MqW3K2LxNXbB/+A8N8kDkBW5+KZHisOtfqJHqcJ4dQ=";
          };

          vendorHash = "sha256-7YbKUeV+Lm7D/5jIqVm71EnRL4FDFops9c8zTXQMS1Y=";
        }
      );
    })
  ];
}
