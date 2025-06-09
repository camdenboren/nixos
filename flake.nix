{
  inputs = {
    # find time-traveling refs at www.nixhub.io and append after nixpkgs/
    nixpkgs = {
      url = "github:nixos/nixpkgs/nixos-unstable";
    };
    nixpkgs-stable = {
      url = "github:nixos/nixpkgs/nixos-24.11";
    };
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    musnix = {
      url = "github:musnix/musnix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    mac-app-util = {
      url = "github:hraban/mac-app-util";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-homebrew = {
      url = "github:zhaofengli/nix-homebrew";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-stable,
      nix-darwin,
      ...
    }@inputs:
    {
      nixosConfigurations = {
        main = nixpkgs.lib.nixosSystem (
          import ./hosts/main {
            inherit
              inputs
              nixpkgs
              nixpkgs-stable
              ;
          }
        );
        mainvm = nixpkgs.lib.nixosSystem (
          import ./hosts/mainvm {
            inherit
              inputs
              nixpkgs
              nixpkgs-stable
              ;
          }
        );
        macvm = nixpkgs.lib.nixosSystem (
          import ./hosts/macvm {
            inherit
              inputs
              nixpkgs
              nixpkgs-stable
              ;
          }
        );
        media = nixpkgs.lib.nixosSystem (
          import ./hosts/media {
            inherit
              inputs
              nixpkgs
              nixpkgs-stable
              ;
          }
        );
      };
      darwinConfigurations = {
        mac = nix-darwin.lib.darwinSystem (
          import ./hosts/mac {
            inherit
              inputs
              nixpkgs
              nixpkgs-stable
              nix-darwin
              ;
          }
        );
      };
    };
}
