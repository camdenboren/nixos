{
  inputs = {
    # find time-traveling refs at www.nixhub.io and append after nixpkgs/
    nixpkgs = {
      url = "github:nixos/nixpkgs/nixos-unstable";
    };
    nixpkgs-stable = {
      url = "github:nixos/nixpkgs/nixos-26.05";
    };
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
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
    alc-calc = {
      url = "github:camdenboren/alc-calc/feat/web";
    };
    chatbot-util = {
      url = "github:collegiate-edu-nation/chatbot-util";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nix-darwin.follows = "nix-darwin";
    };
    fetch-rs = {
      url = "github:camdenboren/fetch-rs";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nix-darwin.follows = "nix-darwin";
    };
    yt-x = {
      url = "github:Benexl/yt-x";
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
    let
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];
      forEachSupportedSystem =
        function:
        nixpkgs.lib.genAttrs supportedSystems (
          system:
          function {
            pkgs = nixpkgs.legacyPackages.${system};
          }
        );
    in
    {
      nixosConfigurations = {
        main = nixpkgs.lib.nixosSystem (
          import ./hosts/main {
            inherit
              inputs
              self
              nixpkgs
              nixpkgs-stable
              ;
          }
        );
        mainvm = nixpkgs.lib.nixosSystem (
          import ./hosts/mainvm {
            inherit
              inputs
              self
              nixpkgs
              nixpkgs-stable
              ;
          }
        );
        macvm = nixpkgs.lib.nixosSystem (
          import ./hosts/macvm {
            inherit
              inputs
              self
              nixpkgs
              nixpkgs-stable
              ;
          }
        );
        media = nixpkgs.lib.nixosSystem (
          import ./hosts/media {
            inherit
              inputs
              self
              nixpkgs
              nixpkgs-stable
              ;
          }
        );
      };
      darwinConfigurations = {
        ci = import ./tests/mac.nix {
          darwinConfiguration = self.darwinConfigurations.mac;
          activate = true;
        };
        mac = nix-darwin.lib.darwinSystem (
          import ./hosts/mac {
            inherit
              inputs
              self
              nixpkgs
              nixpkgs-stable
              nix-darwin
              ;
          }
        );
      };
      checks = forEachSupportedSystem (
        { pkgs, ... }:
        nixpkgs.lib.optionalAttrs (pkgs.stdenv.hostPlatform.system == "x86_64-linux") {
          main = import ./tests/main.nix {
            inherit pkgs;
            nixosConfiguration = import ./hosts/main {
              inherit
                inputs
                self
                nixpkgs
                nixpkgs-stable
                ;
            };
          };
          mainvm = import ./tests/mainvm.nix {
            inherit pkgs;
            nixosConfiguration = import ./hosts/mainvm {
              inherit
                inputs
                self
                nixpkgs
                nixpkgs-stable
                ;
            };
          };
          media = import ./tests/media.nix {
            inherit pkgs;
            nixosConfiguration = import ./hosts/media {
              inherit
                inputs
                self
                nixpkgs
                nixpkgs-stable
                ;
            };
          };
        }
        // nixpkgs.lib.optionalAttrs (pkgs.stdenv.hostPlatform.system == "aarch64-linux") {
          macvm = import ./tests/macvm.nix {
            inherit pkgs;
            nixosConfiguration = import ./hosts/macvm {
              inherit
                inputs
                self
                nixpkgs
                nixpkgs-stable
                ;
            };
          };
        }
        # Darwin testing approach from https://github.com/Mic92/fast-nix-gc
        // nixpkgs.lib.optionalAttrs pkgs.stdenv.hostPlatform.isDarwin {
          mac =
            (import ./tests/mac.nix {
              darwinConfiguration = self.darwinConfigurations.mac;
            }).system;
        }
      );
    };
}
