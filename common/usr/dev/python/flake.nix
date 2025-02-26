{
  description = "Python Development Environment via Nix Flake";

  inputs = {
    nixpkgs = {
      url = "github:nixos/nixpkgs/nixos-unstable";
    };
  };

  outputs =
    { nixpkgs, ... }:
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
      devShells = forEachSupportedSystem (
        { pkgs }:
        {
          default = pkgs.mkShell {
            packages = with pkgs; [
              bashInteractive
              python312
            ];

            shellHook = ''
              export PS1="\n\[\033[1;31m\][devShell:\w]\$\[\033[0m\] "
              echo -e "\nPython Development Environment via Nix Flake\n"
              echo -e "Run: python fileName.py\n" 
              python --version
            '';
          };
        }
      );
    };
}
