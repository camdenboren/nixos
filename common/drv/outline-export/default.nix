{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule (finalAttrs: {
  pname = "outline-export";
  version = "1.2.2";
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "lrstanley";
    repo = "outline-export";
    tag = "v${finalAttrs.version}";
    hash = "sha256-4bpS9AVr7YAaD0jynXWRHhs0kUqmjSLZt/UGkxgfnuE=";
  };

  vendorHash = "sha256-4Q2VyAuZDzZFM8z/Q37lWejXObiWpzWKLQpUJfvpwtE=";

  ldflags = [ "-s" ];

  meta = {
    description = "Utility to export outline collections/documents for usage of backup, replication, etc";
    homepage = "https://github.com/lrstanley/outline-export";
    changelog = "https://github.com/lrstanley/outline-export/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    mainProgram = "outline-export";
  };
})
