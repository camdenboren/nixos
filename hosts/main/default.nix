{
  inputs,
  nixpkgs-stable,
  ...
}:

let
  hostname = "main";
  system = "x86_64-linux";
  rice = "skyline";
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
    inputs.musnix.nixosModules.musnix
  ];
}
