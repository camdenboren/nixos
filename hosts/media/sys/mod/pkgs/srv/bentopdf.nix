{ pkgs, ... }:

let
  baseDomain = "home.local";
in
{
  services.bentopdf = {
    enable = true;
    package = pkgs.bentopdf.overrideAttrs (
      finalAttrs: prevAttrs: {
        version = "2.8.7";
        src = prevAttrs.src.override {
          tag = "v${finalAttrs.version}";
          hash = "sha256-SduYMgRs5IOLNJx1tHCp/UpUhB8vDzRfLY0ZzTUQrQI=";
        };
        npmDepsHash = "sha256-nKAny59NUuT45GZtXyUVihxbbFYvu1t3PVDBX8gPPws=";
        npmDeps = pkgs.fetchNpmDeps {
          inherit (finalAttrs) src;
          name = "${finalAttrs.pname}-${finalAttrs.version}-npm-deps";
          hash = finalAttrs.npmDepsHash;
        };
      }
    );
    domain = "pdf.${baseDomain}";
    nginx = {
      enable = true;
      virtualHost = {
        forceSSL = true;
        enableACME = true;
      };
    };
  };
}
