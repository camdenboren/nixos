{
  inputs = {
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
      mainCfg = import ./hosts/main {
        inherit
          inputs
          self
          nixpkgs
          nixpkgs-stable
          ;
      };
      mainvmCfg = import ./hosts/mainvm {
        inherit
          inputs
          self
          nixpkgs
          nixpkgs-stable
          ;
      };
      macvmCfg = import ./hosts/macvm {
        inherit
          inputs
          self
          nixpkgs
          nixpkgs-stable
          ;
      };
      mediaCfg = import ./hosts/media {
        inherit
          inputs
          self
          nixpkgs
          nixpkgs-stable
          ;
      };
      macCfg = import ./hosts/mac {
        inherit
          inputs
          self
          nixpkgs
          nixpkgs-stable
          nix-darwin
          ;
      };
    in
    {
      nixosConfigurations = {
        main = nixpkgs.lib.nixosSystem mainCfg;
        mainvm = nixpkgs.lib.nixosSystem mainvmCfg;
        macvm = nixpkgs.lib.nixosSystem macvmCfg;
        media = nixpkgs.lib.nixosSystem mediaCfg;
      };
      darwinConfigurations = {
        ci = import ./tests/hosts/mac.nix {
          darwinConfiguration = self.darwinConfigurations.mac;
          activate = true;
        };
        mac = nix-darwin.lib.darwinSystem macCfg;
      };
      checks = forEachSupportedSystem (
        { pkgs, ... }:
        nixpkgs.lib.optionalAttrs (pkgs.stdenv.hostPlatform.system == "x86_64-linux") {
          main = import ./tests/hosts/main.nix {
            inherit pkgs;
            nixosConfiguration = mainCfg;
          };
          mainvm = import ./tests/hosts/mainvm.nix {
            inherit pkgs;
            nixosConfiguration = mainvmCfg;
          };
          media = import ./tests/hosts/media.nix {
            inherit pkgs;
            nixosConfiguration = mediaCfg;
          };
        }
        // nixpkgs.lib.optionalAttrs (pkgs.stdenv.hostPlatform.system == "aarch64-linux") {
          macvm = import ./tests/hosts/macvm.nix {
            inherit pkgs;
            nixosConfiguration = macvmCfg;
          };
        }
        # Darwin testing approach from https://github.com/Mic92/fast-nix-gc
        // nixpkgs.lib.optionalAttrs pkgs.stdenv.hostPlatform.isDarwin {
          mac =
            (import ./tests/hosts/mac.nix {
              darwinConfiguration = self.darwinConfigurations.mac;
            }).system;
        }
      );
    };
}
