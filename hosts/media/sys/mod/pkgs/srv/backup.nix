{ pkgs, ... }:

# as this is a mirror-only backup, there's significant room for improvement
# in implementing snapshot-based backups-additional work will also make sense
# in creating functions for the more repetitive commands (like `rsync` and
# `pg_dump`); this at least provides a quick way to protect against hard
# drive failures or network attacks (the backup drive is offline), however,
# so it's better than nothing
let
  backupPath = "/run/media/camdenboren/backup";
  script = ''
    set -euo pipefail
    failed() {
      echo $'\e[31m[backup] FAILED.\e[0m' >&2
      curl -d "Backup failed" -L \
        https://ntfy.home.local/"$NTFY_TOPIC"
      exit 1
    }
    trap 'failed' ERR

    HDD_PATH=/mnt/media
    BACKUP_PATH=${backupPath}
    MAIN_IP=192.168.1.88
    USER_PATH=/home/camdenboren

    if [[ ! -f "$BACKUP_PATH/.backup-marker" ]]; then
      echo "backup drive marker missing at $BACKUP_PATH, skipping" >&2
      exit 0
    fi

    #
    # Music and media
    #

    echo $'\e[36m[backup:media] Starting...\e[0m'
    ${pkgs.rsync}/bin/rsync -cavuP --delete \
      camdenboren@"$MAIN_IP":"$USER_PATH"/Music/music/ \
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
      ".backup '/run/media/camdenboren/backup/backups/Services/openobserve.sqlite'"
    cd "$USER_PATH"
    echo $'\e[32m[backup:openobserve] Succeeded.\e[0m'

    #
    # Outline
    #

    echo $'\e[36m[backup:outline] Starting...\e[0m'
    ${pkgs.outline-export}/bin/outline-export \
      --url "https://notes.home.local" \
      --export-path "$BACKUP_PATH"/backups/Services/outline.zip \
      --format json
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
    rm -rf -- "$(pwd)"
    cd "$USER_PATH"
    echo $'\e[32m[backup:lubelogger] Succeeded.\e[0m'

    #
    # Actual
    #

    echo $'\e[36m[backup:actual] Starting...\e[0m'
    ${pkgs.actual-cli}/bin/actual-cli budgets download \
      "$ACTUAL_SYNC_ID" \
      --data-dir "$USER_PATH"/Downloads
    mv "$USER_PATH"/Downloads/My-Finances-* \
      "$USER_PATH"/Downloads/$(date +%Y-%m-%d)-My\ Finances
    rm "$USER_PATH"/Downloads/My\ Finances/cache.sqlite
    ${pkgs.zip}/bin/zip "$BACKUP_PATH"/backups/Services/actual.zip \
      "$USER_PATH"/Downloads/*-My\ Finances
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

    echo $'\e[32m[backup] Succeeded.\e[0m'
    curl -d "Backup finished" -L \
      https://ntfy.home.local/"$NTFY_TOPIC"
  '';

  pgScript = ''
    set -euo pipefail
    failed() {
      echo $'\e[31m[backup-postgres] FAILED.\e[0m' >&2
      curl -d "Postgres backup failed" -L \
        https://ntfy.home.local/"$NTFY_TOPIC"
      exit 1
    }
    trap 'failed' ERR

    if [[ ! -f ${backupPath}/.backup-marker ]]; then
      echo "backup drive marker missing at ${backupPath}, skipping" >&2
      exit 0
    fi

    BACKUP_PATH=${backupPath}/backups/Services

    echo $'\e[36m[backup-postgres] Starting...\e[0m'
    ${pkgs.postgresql}/bin/pg_dump -U postgres homebox \
      > "$BACKUP_PATH"/homebox.sql
    ${pkgs.postgresql}/bin/pg_dump -U postgres immich \
      > "$BACKUP_PATH"/immich.sql
    ${pkgs.postgresql}/bin/pg_dump -U postgres outline \
      > "$BACKUP_PATH"/outline.sql
    echo $'\e[32m[backup-postgres] Succeeded.\e[0m'

    curl -d "Postgres backup finished" -L \
      https://ntfy.home.local/"$NTFY_TOPIC"
  '';
in
{
  systemd = {
    services = {
      backup = {
        description = "Backup all Homelab services and files";
        inherit script;
        after = [
          "run-media-camdenboren-backup.mount"
          "backup-postgres.service"
        ];

        unitConfig.RequiresMountsFor = [ backupPath ];
        serviceConfig = {
          Type = "oneshot";
          User = "root";
          # ntfy, outline-export, and actual-cli need several secrets
          EnvironmentFile = "/var/lib/secrets/backup";
          NoNewPrivileges = true;
          PrivateTmp = true;
        };
      };

      backup-postgres = {
        description = "Backup all Homelab postgres dbs";
        script = pgScript;
        after = [ "run-media-camdenboren-backup.mount" ];

        unitConfig.RequiresMountsFor = [ backupPath ];
        serviceConfig = {
          Type = "oneshot";
          User = "postgres";
          # ntfy needs it's secret topic
          EnvironmentFile = "/var/lib/secrets/backup";
          NoNewPrivileges = true;
          PrivateTmp = true;
        };
      };
    };

    targets.backup-all = {
      description = "Run all Homelab backups";
      wantedBy = [ "multi-user.target" ];
      wants = [
        "backup.service"
        "backup-postgres.service"
      ];
    };

    paths.backup-autorun = {
      description = "Run backups when backup drive is connected";
      wantedBy = [ "multi-user.target" ];
      pathConfig = {
        PathExists = "${backupPath}/.backup-marker";
        Unit = "backup-all.target";
      };
    };
  };
}
