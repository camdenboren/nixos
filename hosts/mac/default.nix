{
  inputs,
  nixpkgs-stable,
  ...
}:

let
  hostname = "mac";
  system = "aarch64-darwin";
  rice = "nothin";
  pkgs-stable = nixpkgs-stable.legacyPackages.${system};
in
{
  specialArgs = {
    inherit
      inputs
      hostname
      system
      pkgs-stable
      ;
  };
  modules = [
    ./sys
    inputs.home-manager.darwinModules.home-manager
    {
      home-manager = {
        extraSpecialArgs = {
          inherit
            inputs
            hostname
            system
            pkgs-stable
            rice
            ;
        };
        backupFileExtension = "backup";
        users = {
          "camdenboren" = import ./usr;
        };
      };
    }
    inputs.nix-homebrew.darwinModules.nix-homebrew
    {
      nix-homebrew = {
        enable = true;
        user = "camdenboren";
        autoMigrate = true;
      };
    }
  ];
}
