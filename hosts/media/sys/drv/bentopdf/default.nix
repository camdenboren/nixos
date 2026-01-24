{ buildNpmPackage, fetchFromGitHub }:

buildNpmPackage rec {
  pname = "bentopdf";
  version = "1.16.0";
  src = fetchFromGitHub {
    owner = "alam00000";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-hJEPKIH+s4eVcev+Eqku8BnDOvBH56H3SdDPDf3+joM=";
  };

  # regenerate via
  # 1. Running: $(npm rm xlsx && npm install xlsx && npm rm embedpdf-snippet && npm install embedpdf-snippet-i18n@1.5.0-1)
  # 2. Replacing all instances of `embedpdf-snippet` -> `embedpdf-snippet-i18n`
  #   a. `src/js/logic/edit-pdf-page.ts` has two offenders
  #   b. `vite.config.ts` has one
  # 3. Regenerating patch (don't add changes) $(git diff > unvendored-deps.patch)
  #
  # note that this exposes end users to vulnerabilities associated w/ using xlsx
  # going w/ another fork will make sense in the future
  patches = [ ./unvendored-deps.patch ];

  npmFlags = [ "--legacy-peer-deps" ];
  npmDepsHash = "sha256-IKIEHYCmaX/6EXdekPv0PfN4WVTYA1q3CkNEs/Y7T6g=";

  # setting `env.SIMPLE_MODE = true;` didn't work
  buildPhase = ''
    SIMPLE_MODE=true npm run build
  '';

  postInstall = ''
    mkdir -p $out/dist
    cp -r dist/* $out/dist
  '';
}
