{
  lib,
  buildGoLatestModule,
  fetchFromGitHub,
}:

buildGoLatestModule (finalAttrs: {
  pname = "outline-export";
  version = "1.2.3";
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "lrstanley";
    repo = "outline-export";
    tag = "v${finalAttrs.version}";
    hash = "sha256-MVIvaegO0rQ3Zl8D0BsFPF05uEaKDpaJlQKJUaOxVAc=";
  };

  vendorHash = "sha256-L59ORdfb9q9IqiOVXv893k61Dzb9Znz9eshQF79zQFc=";

  ldflags = [ "-s" ];

  meta = {
    description = "Utility to export outline collections/documents for usage of backup, replication, etc";
    homepage = "https://github.com/lrstanley/outline-export";
    changelog = "https://github.com/lrstanley/outline-export/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    mainProgram = "outline-export";
  };
})
