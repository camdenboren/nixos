{ buildNpmPackage, fetchFromGitHub }:

buildNpmPackage rec {
  pname = "bentopdf";
  version = "2.4.0";
  src = fetchFromGitHub {
    owner = "alam00000";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-nzrVLs0x/mRCEtTOXXuhbWd2BJAOI262BcZ8r4eJdnw=";
  };

  # regenerate via
  # 1. Running: $(npm rm embedpdf-snippet && npm install embedpdf-snippet-i18n@2.3.0-1)
  # 2. Replacing all instances of `embedpdf-snippet` -> `embedpdf-snippet-i18n`
  #   a. `src/js/logic/edit-pdf-page.ts` has two offenders
  #   b. `vite.config.ts` has one
  # 3. Regenerating patch (don't add changes) $(git diff > unvendored-deps.patch)
  patches = [ ./unvendored-deps.patch ];

  npmFlags = [ "--legacy-peer-deps" ];
  npmDepsHash = "sha256-GTooExkMYt2wlBJA0qHt2ZrqmHQnwYmW3w/l9U8FNyQ=";

  # setting `env.SIMPLE_MODE = true;` didn't work
  buildPhase = ''
    SIMPLE_MODE=true npm run build
  '';

  postInstall = ''
    mkdir -p $out/dist
    cp -r dist/* $out/dist
  '';
}
