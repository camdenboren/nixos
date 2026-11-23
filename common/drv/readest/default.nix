{
  readest,
}:

# Linux desktop build of Readest that loads its runtime configuration from the
# self-hosted web stack instead of the Readest Cloud defaults baked into the
# stock package.
#
# The Tauri build has no runtime-config route of its own, so inject an external
# <Script> pointing at the web client's /runtime-config.js. That script supplies
# the Supabase URL, anon key, API base URL, and SELF_HOSTED=true at startup. The
# only thing baked into the binary is the public URL of that script.
readest.overrideAttrs (old: {
  patches = (old.patches or [ ]) ++ [
    ./runtime-config.patch
  ];

  preBuild = ''
    export NEXT_PUBLIC_SELFHOSTED_RUNTIME_CONFIG_URL="https://read.home.local/runtime-config.js"
    export NEXT_PUBLIC_SUPABASE_URL="https://read.home.local"
    export NEXT_PUBLIC_API_BASE_URL="https://read.home.local"
  ''
  + (old.preBuild or "");

  postPatch = (old.postPatch or "") + ''
    # Allow the self-hosted runtime-config script in the Tauri CSP. The pattern
    # also appears in frame-src; adding the origin there is harmless.
    substituteInPlace src-tauri/tauri.conf.json \
      --replace-fail 'stripe.com"' 'stripe.com https://read.home.local"'
  '';
})
