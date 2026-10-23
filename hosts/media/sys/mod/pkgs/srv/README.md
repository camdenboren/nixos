# Homelab

[default.nix](default.nix) imports each service module plus shared system utilities. Most applications use native NixOS services; Penpot uses Podman containers and draw.io is served directly from `pkgs.drawio`. Vector ships journald logs and a variety of hardware metrics (including the UPSs via the [upsMetrics](../../../../../../common/usr/scr/upsMetrics.nix) script) to the OpenObserve observability backend.

## Routing

[nginx.nix](nginx.nix) maps `home.local` to Homepage and application subdomains to
backends. Unless specified below, backend addresses are `127.0.0.1` on `media`.
Ports here describe the configured proxy targets; several services use module
defaults, so keep those defaults aligned with this table when changing inputs.

| Host under `home.local` | Backend                                             | Configuration                                                                                |
| ----------------------- | --------------------------------------------------- | -------------------------------------------------------------------------------------------- |
| Base domain             | Homepage `:8082`                                    | [homepage.nix](homepage.nix)                                                                 |
| `chat`                  | Open WebUI `:8080`                                  | [open-webui.nix](open-webui.nix); Ollama on media and `192.168.1.88:11434`                   |
| `media`                 | Jellyfin `:8096`                                    | [jellyfin.nix](jellyfin.nix)                                                                 |
| `photos`                | Immich `:2283`                                      | [immich.nix](immich.nix)                                                                     |
| `archive`               | Kiwix `:9095`                                       | [kiwix.nix](kiwix.nix)                                                                       |
| `notes`, `dex`          | Outline `:3000`, Dex `:5556`                        | [outline.nix](outline.nix); OIDC login                                                       |
| `design`                | Penpot frontend `:9001`                             | [penpot.nix](penpot.nix)                                                                     |
| `draw`                  | Static `pkgs.drawio`                                | `nginx.nix`; the declared `9040` port is unused                                              |
| `pdf`                   | BentoPDF-managed Nginx vhost                        | [bentopdf.nix](bentopdf.nix); separate from `nginx.nix`'s domain map                         |
| `alc`                   | alc-calc-managed Nginx vhost                        | [alc-calc.nix](alc-calc.nix); separate from `nginx.nix`'s domain map, like BentoPDF          |
| `box`, `car`, `money`   | Homebox `:7745`, LubeLogger `:5000`, Actual `:4000` | [homebox.nix](homebox.nix), [lubelogger.nix](lubelogger.nix), [actual.nix](actual.nix)       |
| `ntfy`                  | ntfy `:2586`                                        | [ntfy-sh.nix](ntfy-sh.nix)                                                                   |
| `sync`                  | Syncthing `:8384`                                   | [Shared Home Manager service](../../../../../../common/usr/mod/pkgs/srv/utils/syncthing.nix) |
| `image`                 | `192.168.1.88:9090`                                 | Remote backend on `main`                                                                     |
| `log`                   | OpenObserve `:5080`                                 | [openobserve/default.nix](openobserve/default.nix)                                           |
| `util`                  | `192.168.1.93:8080`                                 | Remote backend on `mac`, with Nginx basic auth                                               |

`kiwix.nix` also starts a separate `kiwix-mcp` systemd service using streamable HTTP and `KIWIX_BASE_URL=http://localhost:9095`.

## DNS, TLS, and runtime files

- [tailscale.nix](tailscale.nix) allows Tailscale alongside Mullvad using nftables split-tunnel marks.
- [unbound.nix](unbound.nix) resolves the `home.local` zone to `100.99.5.32` on the
  Tailscale interface, after `tailscaled-autoconnect.service`. Tailnet clients must
  use this resolver for the zone; client DNS setup is outside this directory.
- [Shared networking](../../../../../../common/sys/mod/cfg/hw/networking.nix)
  maps local hosts to `192.168.1.78` (loopback on media), opens HTTP/HTTPS on media
  and DNS on its Tailscale interface, and installs `home-local.pem` in Linux trust.
  Its comments describe manual macOS Keychain trust.
- [minica.nix](minica.nix) disables the NixOS ACME order services and timers while
  preserving the module's minica certificate implementation and the
  `security.acme.certs` interface used by Nginx. Its timer checks certificate
  expiry and restarts the upstream minica service when renewal is due. Dependent
  services reload after certificate generation, and the timer retries failed
  reloads; no ACME client starts. The checked-in `home-local.pem` must remain
  aligned with the persistent root in `/var/lib/acme/.minica` for client trust.
- Runtime secrets under `/run/secrets` are managed by the
  [sops-nix configuration](../../../../../../common/sec/README.md), including Tailscale,
  Dex/Outline, Homebox, Penpot, OpenObserve, backups, and shared host services.
  The Penpot file supplies container environment variables. Outline reuses Dex's client
  secret and currently disables Node TLS verification.
- Immich stores media at `/mnt/media/Pictures`. Kiwix reads
  `/mnt/media/Archives/library.xml`; add archives with `kiwix-manage library.xml add
file.zim` from that directory. Penpot persists assets and PostgreSQL data in
  `penpot_penpot_assets` and `penpot_penpot_postgres_v15` Podman volumes.

## Backups

- [backup.nix](backup.nix) defines the `backup.service` (root) oneshot, mirroring media, documents,
  and service exports/dumps to the offline USB drive. Ntfy reports
  success/failure; secrets live in `/run/secrets/backup`.
- Hotplugging the drive fires a udev rule on its hardware `ID_SERIAL`
  (`backupSerial`) → `backup.service`. Fill that in from
  `udevadm info --query=property --name=/dev/sdX | grep '^ID_SERIAL'` on media
  with the drive plugged in, using the full `ID_SERIAL` rather than
  `ID_SERIAL_SHORT`. Matching the disk rather than a filesystem UUID keeps the
  trigger working across a reformat and needs no partition table, but it does
  depend on the drive reporting a serial — if that value is left as the
  placeholder, backups silently never run. The scripts don't assume the udisks2
  mountpoint: since udev fires before the automount lands, they poll ~30s and
  resolve the drive's mount by the same `ID_SERIAL`. So a surcharged
  `backup` volume landing at `backup-1` is still found. The drive is
  deliberately not declared to systemd, since udisks2 mounts it out-of-band and
  a `.mount` requirement would fail the job.
- On media, `/var/lib/backup/armed` is a local opt-in (`install -d -m 0755
/var/lib/backup && touch /var/lib/backup/armed`); leave it absent on a fresh
  media, or the `rsync --delete` mirrors wipe the drive from empty sources. Arm
  after restoring, `rm` before re-imaging.
- Mirror-only; snapshots are future work. Reformatting the drive keeps its
  serial, so the trigger stays live and the scripts re-seed the fresh volume.
- The `main` music rsync uses a passphrase-less root key at
  `/root/.ssh/backup-main` (never check it in), restricted on `main` to `from=`
  - `rrsync -ro`, so theft costs a music-dir read, not a shell. The client pulls
    `camdenboren@main:.` — not `:/` — with
    `-e "ssh -i /root/.ssh/backup-main -o BatchMode=yes"`.
