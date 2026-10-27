{
  config,
  lib,
  pkgs,
  system,
  ...
}:

let
  isDarwin = lib.hasSuffix "-darwin" system;
  script = pkgs.writeShellApplication {
    name = "refresh-references";
    runtimeInputs = with pkgs; [
      coreutils
      gitMinimal
      gh
      xerj-bin
    ];
    text = ''
      repos_root="''${1:-$HOME/Documents/Repos}"
      metadata_dir="$repos_root/metadata"
      state_root="''${XDG_STATE_HOME:-$HOME/.local/state}/xerj/refresh-references"
      mkdir -p "$metadata_dir" "$state_root"
      work_dir="$(mktemp -d "$metadata_dir/.refresh.XXXXXX")"
      trap 'rm -rf "$work_dir"' EXIT

      export GIT_TERMINAL_PROMPT=0 GH_PROMPT_DISABLED=1
      failed=0
      metadata_ready=false
      fields="number,title,body,url,state,createdAt,updatedAt,closedAt,author,labels"

      index_folder() {
        local folder="$1" prefix="$2" status=0
        echo "Indexing $folder as $prefix"
        xerj autoindex "$folder" \
          --prefix "$prefix"  \
          --no-graph \
          --yes \
          || status=$?
        if (( status != 0 && status != 3 )); then
          echo "Could not index $folder (exit $status)" >&2
          failed=1
        fi
      }

      for repo in NixOS/nixpkgs nix-darwin/nix-darwin nix-community/home-manager; do
        name="''${repo##*/}"
        checkout="$repos_root/$name"
        checkout_ready=false
        echo "Refreshing $repo"

        if [[ ! -e "$checkout" ]]; then
          if git clone --depth 1 --single-branch "https://github.com/$repo.git" "$work_dir/$name" \
            && mv "$work_dir/$name" "$checkout"; then
            echo "Cloned $name"
            checkout_ready=true
          else
            echo "Could not clone $repo" >&2
            failed=1
          fi
        elif [[ -e "$checkout/.git" ]]; then
          if git -C "$checkout" pull --ff-only; then
            checkout_ready=true
          else
            echo "Could not fast-forward $checkout" >&2
            failed=1
          fi
        else
          echo "Not a Git checkout: $checkout" >&2
          failed=1
        fi

        if [[ "$checkout_ready" == true ]]; then
          index_folder "$checkout" "refs-$name"
        fi

        for kind in issue pr; do
          json_fields="$fields"
          if [[ "$kind" == pr ]]; then
            json_fields+=",mergedAt,mergeCommit,baseRefName,headRefName"
            filename="$name-prs.json"
          else
            filename="$name-issues.json"
          fi

          if gh "$kind" list --repo "$repo" --state all --limit 1000 \
            --search 'sort:updated-desc' --json "$json_fields" >"$work_dir/$filename" \
            && mv "$work_dir/$filename" "$metadata_dir/$filename"; then
            echo "Updated $filename"
            metadata_ready=true
          else
            echo "Could not refresh $filename; keeping the previous snapshot" >&2
            failed=1
          fi
        done
      done

      if [[ "$metadata_ready" == true ]]; then
        index_folder "$metadata_dir" "refs-metadata"
      fi

      exit "$failed"
    '';
  };
  logPath = "${config.home.homeDirectory}/Library/Logs/refresh-references.log";
in
{
  home.packages = [ script ];

  systemd.user = lib.mkIf (!isDarwin) {
    services.refresh-references = {
      Unit.Description = "Refresh Nix reference repos and GitHub issues/PRs";
      Service = {
        Type = "oneshot";
        ExecStart = "${script}/bin/refresh-references";
        NoNewPrivileges = true;
        PrivateTmp = true;
        ProtectSystem = true;
        UMask = "0027";
      };
    };
    timers.refresh-references = {
      Unit.Description = "Refresh Nix references daily at 09:30";
      Timer = {
        OnCalendar = "*-*-* 09:30:00";
        AccuracySec = "1s";
        Persistent = true;
      };
      Install.WantedBy = [ "timers.target" ];
    };
  };

  launchd.agents.refresh-references = lib.mkIf isDarwin {
    enable = true;
    config = {
      ProgramArguments = [ "${script}/bin/refresh-references" ];
      StartCalendarInterval = {
        Hour = 9;
        Minute = 30;
      };
      RunAtLoad = false;
      StandardOutPath = logPath;
      StandardErrorPath = logPath;
    };
  };
}
