{ buildNpmPackage, fetchFromGitHub }:

buildNpmPackage rec {
  pname = "bentopdf";
  version = "2.8.5";
  src = fetchFromGitHub {
    owner = "alam00000";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-/Jzhi291hxsyBGde72wKXkk6TSBMKUSmCdVtLWrvBzQ=";
  };

  # regenerate in most recent repo tag via
  # 1. $(shell nodejs gnused)
  # 2. $(npm rm embedpdf-snippet && npm i @embedpdf/snippet@2.9.1 && sed -i 's|embedpdf-snippet|@embedpdf/snippet|g' src/js/logic/edit-pdf-page.ts && sed -i 's|embedpdf-snippet|@embedpdf/snippet|g' vite.config.ts && git diff > unvendored-deps.patch && cp -f unvendored-deps.patch ~/etc/nixos/hosts/media/sys/drv/bentopdf/)
  patches = [ ./unvendored-deps.patch ];

  npmFlags = [ "--legacy-peer-deps" ];
  npmDepsHash = "sha256-ImWFzz99oE8dQtHK7MVBJZ4pXO1QDAjqkINzcVNsGmM=";

  # setting `env.SIMPLE_MODE = true;` didn't work
  buildPhase = ''
    SIMPLE_MODE=true npm run build
  '';

  postInstall = ''
    mkdir -p $out/dist
    cp -r dist/* $out/dist
  '';
}
