{ pkgs, ... }:

# as this is a mirror-only backup, there's significant room for improvement
# in implementing snapshot-based backups-additional work will also make sense
# in creating functions for the more repetitive commands (like `rsync` and
# `pg_dump`); this at least provides a quick way to protect against hard
# drive failures or network attacks (the backup drive is offline), however,
# so it's better than nothing
let
  # local opt-in, so a fresh media can't wipe the drive with `--delete`
  armPath = "/var/lib/backup/armed";
  # drive's ID_SERIAL (full form, not ID_SERIAL_SHORT), from
  # `udevadm info --query=property --name=/dev/sdX`
  backupSerial = "WDC_WD140EDGZ-11B2DA2_6AGR8YAT";
  # Find the drive's mount via its udev ID_SERIAL; don't hardcode the mount
  # path since udisks2 may suffix it. polls, as udev fires before automount.
  mountResolve = ''
    if [[ ! -f "${armPath}" ]]; then
      echo $'\e[33m[backup] Not armed at ${armPath}, skipping.\e[0m' >&2
      exit 0
    fi

    find_drive_mnt() {
      for src in $(${pkgs.util-linux}/bin/findmnt -rn -o SOURCE \
        | ${pkgs.gnugrep}/bin/grep '^/dev/' || true); do
        src="''${src%%\[*}"
        if [[ "$(${pkgs.systemd}/bin/udevadm info -q property --name "$src" \
          2>/dev/null \
          | ${pkgs.gnugrep}/bin/grep -Fx "ID_SERIAL=${backupSerial}" \
          || true)" ]]; then
          tgt="$(${pkgs.util-linux}/bin/findmnt -rn -o TARGET --source "$src")"
          # prefer udisks' mount if the drive has multiple partition mounts
          echo "$tgt" | ${pkgs.gnugrep}/bin/grep -m1 '^/run/' \
            || echo "$tgt" | ${pkgs.coreutils}/bin/head -n1
          return 0
        fi
      done
      return 1
    }

    BACKUP_PATH=""
    for _ in {1..30}; do
      if m="$(find_drive_mnt)" && [[ -n "$m" ]]; then
        BACKUP_PATH="$m"
        break
      fi
      sleep 1
    done
    if [[ -z "$BACKUP_PATH" ]]; then
      echo $'\e[33m[backup] Drive not mounted, skipping.\e[0m' >&2
      exit 0
    fi
  '';

  script = ''
    set -euo pipefail
    failed() {
      echo $'\e[31m[backup] FAILED.\e[0m' >&2
      ${pkgs.curl}/bin/curl -d "Backup failed" -L \
        https://ntfy.home.local/"$NTFY_TOPIC"
      exit 1
    }
    trap 'failed' ERR

    HDD_PATH=/mnt/media
    MAIN_IP=192.168.1.88
    USER_PATH=/home/camdenboren

    ${mountResolve}

    #
    # Jellyfin
    #

    echo $'\e[36m[backup:jellyfin] Starting...\e[0m'
    cd /var/lib/jellyfin/data/backups/
    cp -f \
      "$(ls -AFt | grep -v '/$' | head -1)" \
      "$BACKUP_PATH"/backups/Services/jellyfin.zip
    cd "$USER_PATH"
    echo $'\e[32m[backup:jellyfin] Succeeded.\e[0m'

    #
    # Openobserve
    #

    echo $'\e[36m[backup:openobserve] Starting...\e[0m'
    cd /var/lib/openobserve/db
    ${pkgs.sqlite}/bin/sqlite3 metadata.sqlite \
      ".backup '$BACKUP_PATH/backups/Services/openobserve.sqlite'"
    cd "$USER_PATH"
    echo $'\e[32m[backup:openobserve] Succeeded.\e[0m'

    #
    # Outline
    #

    echo $'\e[36m[backup:outline] Starting...\e[0m'
    ${pkgs.outline-export}/bin/outline-export \
      --url "https://notes.home.local" \
      --export-path "$BACKUP_PATH"/backups/Services/Outline-export.json.zip \
      --format json
    ${pkgs.coreutils}/bin/chown camdenboren \
      "$BACKUP_PATH"/backups/Services/Outline-export.json.zip
    echo $'\e[32m[backup:outline] Succeeded.\e[0m'

    #
    # Lubelogger
    #

    echo $'\e[36m[backup:lubelogger] Starting...\e[0m'
    cd "$(mktemp -d)"
    mkdir -p data config
    cp /var/lib/lubelogger/data/cartracker.db data/
    cp /var/lib/lubelogger/data/config/userConfig.json config/
    ${pkgs.zip}/bin/zip "$BACKUP_PATH"/backups/Services/lubelogger.zip \
      data/cartracker.db config/userConfig.json
    ${pkgs.coreutils}/bin/chown camdenboren \
      "$BACKUP_PATH"/backups/Services/lubelogger.zip
    rm -rf -- "$(pwd)"
    cd "$USER_PATH"
    echo $'\e[32m[backup:lubelogger] Succeeded.\e[0m'

    #
    # Actual
    #

    echo $'\e[36m[backup:actual] Starting...\e[0m'
    actual_dir="$USER_PATH/Downloads/$(date +%Y-%m-%d)-My Finances"
    actual_zip="$BACKUP_PATH/backups/Services/actual.zip"
    ${pkgs.actual-cli}/bin/actual-cli budgets download \
      "$ACTUAL_SYNC_ID" \
      --data-dir "$USER_PATH"/Downloads
    mv "$USER_PATH"/Downloads/My-Finances-* "$actual_dir"
    rm -f "$actual_dir/cache.sqlite"
    cd "$USER_PATH/Downloads"
    rm -f "$actual_zip"
    ${pkgs.zip}/bin/zip -r "$actual_zip" "''${actual_dir##*/}"
    cd "$USER_PATH"
    rm -rf -- "$actual_dir"
    ${pkgs.coreutils}/bin/chown camdenboren \
      "$BACKUP_PATH"/backups/Services/actual.zip
    echo $'\e[32m[backup:actual] Succeeded.\e[0m'

    #
    # Cemu
    #

    echo $'\e[36m[backup:cemu] Starting...\e[0m'
    cd "$USER_PATH"/.local/share/Cemu/mlc01/usr/save/00050000
    ${pkgs.zip}/bin/zip -r \
      "$BACKUP_PATH"/backups/Services/Cemu/zelda.zip \
      1019e500
    cd "$USER_PATH"
    echo $'\e[32m[backup:cemu] Succeeded.\e[0m'

    #
    # Penpot
    #

    echo $'\e[36m[backup:penpot] Starting...\e[0m'
    ${pkgs.podman}/bin/podman exec -i \
      penpot-penpot-postgres pg_dump -U penpot penpot \
      > "$BACKUP_PATH"/backups/Services/penpot_penpot_postgres.sql
    ${pkgs.podman}/bin/podman volume export penpot_penpot_assets -o \
      "$BACKUP_PATH"/backups/Services/penpot_penpot_assets.tar
    echo $'\e[32m[backup:penpot] Succeeded.\e[0m'

    #
    # Postgres dbs
    #

    echo $'\e[36m[backup:postgres] Starting...\e[0m'
    ${pkgs.util-linux}/bin/runuser -u postgres -- \
      ${pkgs.postgresql}/bin/pg_dump -U postgres homebox \
      > "$BACKUP_PATH"/backups/Services/homebox.sql
    ${pkgs.util-linux}/bin/runuser -u postgres -- \
      ${pkgs.postgresql}/bin/pg_dump -U postgres immich \
      > "$BACKUP_PATH"/backups/Services/immich.sql
    ${pkgs.util-linux}/bin/runuser -u postgres -- \
      ${pkgs.postgresql}/bin/pg_dump -U postgres outline \
      > "$BACKUP_PATH"/backups/Services/outline.sql
    echo $'\e[32m[backup:postgres] Succeeded.\e[0m'

    #
    # Documents
    #

    echo $'\e[36m[backup:documents] Starting...\e[0m'
    ${pkgs.rsync}/bin/rsync -cavuP --delete \
      "$USER_PATH"/Documents/Assrtd\ Docs/ \
      "$BACKUP_PATH"/backups/Documents/Assrtd\ Docs/
    ${pkgs.rsync}/bin/rsync -cavuP --delete \
      "$USER_PATH"/Documents/Books/ \
      "$BACKUP_PATH"/backups/Documents/Books/
    ${pkgs.rsync}/bin/rsync -cavuP --delete \
      "$USER_PATH"/Documents/Finance/ \
      "$BACKUP_PATH"/backups/Documents/Finance/
    ${pkgs.rsync}/bin/rsync -cavuP --delete \
      "$USER_PATH"/Documents/Fitness/ \
      "$BACKUP_PATH"/backups/Documents/Fitness/
    ${pkgs.rsync}/bin/rsync -cavuP --delete \
      "$USER_PATH"/Documents/Resumes/ \
      "$BACKUP_PATH"/backups/Documents/Resumes/
    ${pkgs.rsync}/bin/rsync -cavuP --delete \
      "$USER_PATH"/Documents/Self\ Study/ \
      "$BACKUP_PATH"/backups/Documents/Self\ Study/
    ${pkgs.rsync}/bin/rsync -cavuP --delete \
      "$USER_PATH"/.config/FreeTube/playlists.db \
      "$BACKUP_PATH"/backups/Documents/FreeTube/
    ${pkgs.rsync}/bin/rsync -cavuP --delete \
      "$USER_PATH"/.config/FreeTube/profiles.db \
      "$BACKUP_PATH"/backups/Documents/FreeTube/
    echo $'\e[32m[backup:documents] Succeeded.\e[0m'

    #
    # Music and media
    #

    echo $'\e[36m[backup:media] Starting...\e[0m'
    ${pkgs.rsync}/bin/rsync -cavuP --delete \
      -e "${pkgs.openssh}/bin/ssh -i /root/.ssh/backup-main -o BatchMode=yes -o IdentitiesOnly=yes" \
      camdenboren@"$MAIN_IP":. \
      "$BACKUP_PATH"/backups/music/
    ${pkgs.rsync}/bin/rsync -cavuP --delete \
      "$HDD_PATH"/Pictures/ \
      "$BACKUP_PATH"/media/Pictures/
    ${pkgs.rsync}/bin/rsync -avuP --delete \
      "$HDD_PATH"/Captures/ \
      "$BACKUP_PATH"/media/Captures/
    ${pkgs.rsync}/bin/rsync -avuP --delete \
      "$HDD_PATH"/Shows/ \
      "$BACKUP_PATH"/media/Shows/
    ${pkgs.rsync}/bin/rsync -avuP --delete \
      "$HDD_PATH"/Movies/ \
      "$BACKUP_PATH"/media/Movies/
    ${pkgs.rsync}/bin/rsync -avuP --delete \
      "$HDD_PATH"/Music/ \
      "$BACKUP_PATH"/media/Music/
    echo $'\e[32m[backup:media] Succeeded.\e[0m'

    echo $'\e[32m[backup] Succeeded.\e[0m'
    ${pkgs.curl}/bin/curl -d "Backup finished" -L \
      https://ntfy.home.local/"$NTFY_TOPIC"
  '';
in
{
  systemd = {
    services = {
      backup = {
        description = "Backup all Homelab services and files";
        inherit script;

        serviceConfig = {
          Type = "oneshot";
          User = "root";
          # ntfy, outline-export, and actual-cli need several secrets
          EnvironmentFile = "/var/lib/secrets/backup";
          NoNewPrivileges = true;
          PrivateTmp = true;
        };
      };
    };
  };

  # Hotplug trigger. The script polls and resolves the mount by ID_SERIAL
  # before the udisks2 automount lands.
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="block", ENV{DEVTYPE}=="disk", \
      ENV{ID_SERIAL}=="${backupSerial}", \
      TAG+="systemd", ENV{SYSTEMD_WANTS}+="backup.service"
  '';
}
