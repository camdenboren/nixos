{
  inputs,
  nixpkgs-stable,
  ...
}:

let
  hostname = "macvm";
  system = "aarch64-linux";
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
    inputs.home-manager.nixosModules.home-manager
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
  ];
}
