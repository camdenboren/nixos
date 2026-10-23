{ self, ... }:

{
  imports = [
    ../../../common/sec
    ./mod/cfg
    ./mod/pkgs
  ];

  system = {
    stateVersion = "24.05";
    # since the config rev of `media` and `main` generally match due to
    # fetch-rs, this prevents `media`'s current closure from being garbage
    # collected on `main`, as it's included in `main`'s gc roots w/o
    # cluttering its userspace (so ssh rebuilds on `media` remain quick
    # regardless of running `clean` on `main`); mainvm is excluded since it's
    # basically just a subset of `main`'s closure, so adding it would
    # increase eval times for no benefit
    extraDependencies = [
      self.nixosConfigurations.media.config.system.build.toplevel
    ];
  };
}
