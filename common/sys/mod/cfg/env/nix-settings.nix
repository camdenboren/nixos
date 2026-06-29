{
  inputs,
  lib,
  system,
  hostname,
  ...
}:

let
  needsBuilder = system == "x86_64-linux" && hostname != "main";
in
{
  nix = {
    nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];
    registry.nixpkgs.flake = inputs.nixpkgs;
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];

      # prevents `error: cannot add path... because it lacks a signature by a trusted key`
      # when copying paths from main
      #
      # i don't set this for all hosts since there's security implications here re.
      # root access https://wiki.nixos.org/wiki/Distributed_build
      #
      # TODO: a more fine-grained approach will likely be a good idea in the future (i.e.,
      # remotebuild user per https://nix.dev/tutorials/nixos/distributed-builds-setup.html)
      trusted-users = lib.optionals needsBuilder [
        "camdenboren"
      ];

      substituters = [
        "https://camdenboren.cachix.org"
        "https://edu-nation.cachix.org"
        "https://cache.nixos-cuda.org"
      ];

      trusted-public-keys = [
        "camdenboren.cachix.org-1:gjOBUYw06+i6CJIjfmVJ+ASrVLoEoOOn/2d6XcQkiFA="
        "edu-nation.cachix.org-1:S2s7ZDuLeFrV2qhfzXWNt+/XlnGxUjvUHv0WI+BvM+0="
        "cache.nixos-cuda.org:74DUi4Ye579gUqzH4ziL9IyiJBlDpMRn9MBN8oNan9M="
      ];
    };
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
}
