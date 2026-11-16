{
  lib,
  buildGoLatestModule,
  buildNpmPackage,
  fetchFromGitHub,
  git,
  jq,
  moreutils,
}:

buildGoLatestModule (finalAttrs: {
  pname = "opengist";
  version = "1.15.3";
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "thomiceli";
    repo = "opengist";
    tag = "v${finalAttrs.version}";
    hash = "sha256-tDmWv3Tsfgskn94RGrREBLyOJir2+OuCo7M7qXSOcZ8=";
  };

  # the Vite bundle is embedded into the Go binary, so build it first and copy
  # the generated manifest/assets into the backend source tree
  frontend = buildNpmPackage {
    pname = "opengist-frontend";
    inherit (finalAttrs) version src;

    # npm complains about the missing version in package.json
    postPatch = ''
      ${lib.getExe jq} '.version = "${finalAttrs.version}"' package.json \
        | ${lib.getExe' moreutils "sponge"} package.json
    '';

    installPhase = ''
      mkdir -p $out
      cp -R public $out
    '';

    npmDepsHash = "sha256-9MqW3K2LxNXbB/+A8N8kDkBW5+KZHisOtfqJHqcJ4dQ=";
  };

  vendorHash = "sha256-7YbKUeV+Lm7D/5jIqVm71EnRL4FDFops9c8zTXQMS1Y=";

  tags = [ "fs_embed" ];

  ldflags = [
    "-s"
    "-X github.com/thomiceli/opengist/internal/config.OpengistVersion=v${finalAttrs.version}"
  ];

  # the internal/git tests shell out to the git binary
  nativeCheckInputs = [ git ];

  # the git tests create directories under $HOME, which the Nix sandbox sets to
  # the non-writable /homeless-shelter, so use a writable temp dir
  preCheck = ''
    export HOME=$(mktemp -d)
  '';

  postPatch = ''
    mkdir -p public/.vite
    cp ${finalAttrs.frontend}/public/.vite/manifest.json public/.vite/manifest.json
    cp -R ${finalAttrs.frontend}/public/assets public/
  '';

  passthru = {
    inherit (finalAttrs) frontend;
  };

  meta = {
    description = "Self-hosted pastebin powered by Git, open-source alternative to Github Gist";
    homepage = "https://github.com/thomiceli/opengist";
    changelog = "https://github.com/thomiceli/opengist/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = lib.licenses.agpl3Only;
    platforms = lib.platforms.unix;
    mainProgram = "opengist";
  };
})
