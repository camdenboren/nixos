# Container images for the homelab, pinned by digest so the pulled bytes are
# fixed and verified. Each image is a `docker save` archive that
# `virtualisation.oci-containers` loads via `imageFile`, so podman never
# pulls at runtime. Refresh the pins with `updatePkg container-images.<name> -u`
# (runs ./update.sh, which rewrites sources.json).
{
  lib,
  dockerTools,
}:

let
  sources = lib.importJSON ./sources.json;

  # nix-update reads `updateScript` and `meta.position` at the top level, and
  # `position` must point inside this flake (pullImage's own position is in nixpkgs)
  mkImage =
    src:
    let
      imageRef = "${src.imageName}:${src.tag}";
    in
    lib.extendDerivation true
      {
        passthru = {
          # `image` for oci-containers; must match what `pullImage` tags the archive with
          inherit imageRef;
          updateScript = ./update.sh;
        };
        # nix-update needs a `version` with a source position, and re-reads it
        # after running updateScript, so it has to track the pinned tag.
        version = src.tag;
        updateScript = ./update.sh;
        meta.position = "${toString ./default.nix}:1";
      }
      (
        dockerTools.pullImage {
          inherit (src) imageName imageDigest hash;
          finalImageName = src.imageName;
          finalImageTag = src.tag;
        }
      );
in
lib.mapAttrs (_: mkImage) sources
