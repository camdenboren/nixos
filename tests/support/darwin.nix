{ user, ocrHelper }:

''
  artifacts="''${SMOKE_ARTIFACTS_DIR:-$PWD/smoke-artifacts}"
  mkdir -p "$artifacts"
  artifacts="$(cd "$artifacts" && pwd -P)"
  if ! (printf 'ok\n' > "$artifacts/.write-probe" && rm -f "$artifacts/.write-probe"); then
    echo "FAIL: cannot write screenshot artifacts to $artifacts" >&2
    ls -ldeO "$artifacts" >&2 || true
    df -h "$artifacts" >&2 || true
    exit 1
  fi
  export PATH="$HOME/.nix-profile/bin:/etc/profiles/per-user/${user}/bin:/run/current-system/sw/bin:$PATH"

  smoke_cli() {
    echo "Testing CLI: $*"
    "$@" 2>&1
  }

  current_pid=""
  cleanup() {
    if [[ -n "$current_pid" ]]; then
      kill "$current_pid" 2>/dev/null || true
      for _ in {1..5}; do
        if ! kill -0 "$current_pid" 2>/dev/null; then
          break
        fi
        sleep 1
      done
      kill -KILL "$current_pid" 2>/dev/null || true
      wait "$current_pid" 2>/dev/null || true
    fi
  }

  ocr_tmp=""
  finish() {
    cleanup
    if [[ -n "$ocr_tmp" ]]; then
      rm -rf "$ocr_tmp"
    fi
  }

  trap finish EXIT
  trap 'exit 130' INT
  trap 'exit 143' TERM

  # compile ocr helper
  if ! swiftc=$(/usr/bin/xcrun --find swiftc) ||
     ! sdk=$(/usr/bin/xcrun --sdk macosx --show-sdk-path) || [[ ! -d "$sdk" ]]; then
    echo "FAIL: Darwin OCR requires installed Xcode/Command Line Tools and a macOS SDK" >&2
    exit 1
  fi
  ocr_tmp=$(mktemp -d)
  ocr_bin="$ocr_tmp/smoke-ocr"
  if ! "$swiftc" -sdk "$sdk" -module-cache-path "$ocr_tmp/modules" ${ocrHelper} -o "$ocr_bin"; then
    echo "FAIL: could not compile Darwin Vision OCR helper" >&2
    exit 1
  fi

  # Preflight exactly the capture command used by the OCR loop, in
  # the same execution context. A file write error is not necessarily
  # a Screen Recording denial; retain filesystem diagnostics.
  capture_probe="$ocr_tmp/capture-probe.png"
  if ! /usr/sbin/screencapture -x -m -t png "$capture_probe" || [[ ! -s "$capture_probe" ]]; then
    echo "FAIL: screencapture could not produce an image at $capture_probe" >&2
    ls -ldeO "$ocr_tmp" "$artifacts" >&2 || true
    df -h "$ocr_tmp" "$artifacts" >&2 || true
    exit 1
  fi
  rm -f "$capture_probe"

  smoke() {
    local bundle="$1" ocr_count="$2"
    shift 2
    local -a ocr=()
    local i
    for ((i = 0; i < ocr_count; i++)); do
      ocr+=("$1")
      shift
    done
    [[ "$1" == -- ]] || { echo "FAIL: invalid smoke arguments" >&2; return 1; }
    shift
    local name executable deadline candidate last rc attempted
    name="$(basename "$bundle" .app)"
    echo "Testing $name"

    executable=$(/usr/libexec/PlistBuddy -c 'Print :CFBundleExecutable' "$bundle/Contents/Info.plist")
    executable="$bundle/Contents/MacOS/$executable"
    test -x "$executable"

    # track the launched PID for liveness and cleanup.
    "$executable" "$@" 2>&1 &
    current_pid=$!
    deadline=$((SECONDS + 60))
    # Store repeated OCR frames in the known-writable mktemp dir.
    # Only completed screenshots and failure diagnostics go to artifacts.
    candidate="$ocr_tmp/$name-candidate.png"
    last="$ocr_tmp/$name-last.png"
    rm -f "$candidate" "$last" "$artifacts/$name.png"
    attempted=0
    while true; do
      if ! kill -0 "$current_pid" 2>/dev/null; then
        ocr_diagnostics failure
        echo "FAIL: $name exited before OCR readiness" >&2
        return 1
      fi
      if (( attempted && SECONDS >= deadline )); then
        ocr_diagnostics timeout
        echo "FAIL: $name OCR readiness timed out (60 seconds)" >&2
        return 1
      fi
      if [[ -s "$candidate" ]]; then mv -f "$candidate" "$last"; fi
      rm -f "$candidate"
      attempted=1
      if ! /usr/sbin/screencapture -x -m -t png "$candidate" || [[ ! -s "$candidate" ]]; then
        ocr_diagnostics failure
        echo "FAIL: screen capture failed or empty for $name at $candidate" >&2
        ls -ldeO "$ocr_tmp" "$artifacts" >&2 || true
        df -h "$ocr_tmp" "$artifacts" >&2 || true
        return 1
      fi
      if "$ocr_bin" "$candidate" "''${ocr[@]}"; then
        if ! kill -0 "$current_pid" 2>/dev/null; then
          ocr_diagnostics failure
          echo "FAIL: $name exited during OCR readiness" >&2
          return 1
        fi
        if ! mv -f "$candidate" "$artifacts/$name.png"; then
          echo "FAIL: cannot publish $name screenshot to $artifacts" >&2
          ls -ldeO "$artifacts" >&2 || true
          df -h "$artifacts" >&2 || true
          return 1
        fi
        rm -f "$last"
        break
      else
        rc=$?
        if (( rc != 1 )); then
          ocr_diagnostics failure
          echo "FAIL: OCR helper error ($rc) for $name" >&2
          return 1
        fi
      fi
      sleep 0.2 # observation cadence only, not a readiness condition
    done
    echo "PASS (OCR): $name rendered all markers in one frame"
    cleanup
    current_pid=""
  }

  ocr_diagnostics() {
    local reason="$1" image="$candidate"
    if [[ ! -s "$image" ]]; then image="$last"; fi
    printf 'Expected OCR marker: %s\n' "''${ocr[@]}" >&2
    if [[ -s "$image" ]]; then
      cp -f "$image" "$artifacts/$name-$reason.png"
      SMOKE_OCR_DUMP=1 "$ocr_bin" "$image" "''${ocr[@]}" || true
    fi
  }
''
