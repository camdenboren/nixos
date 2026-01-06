{
  inputs,
  nixpkgs-stable,
  ...
}:

let
  hostname = "media";
  system = "x86_64-linux";
  rice = "coral";
  pkgs-stable = nixpkgs-stable.legacyPackages.${system};
  pkgs-stable-new = nixpkgs-stable.legacyPackages.${system};
in
{
  specialArgs = {
    inherit
      inputs
      hostname
      system
      rice
      pkgs-stable
      pkgs-stable-new
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
            rice
            pkgs-stable
            pkgs-stable-new
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
