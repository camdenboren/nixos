{
  description = "C/C++ Development Environment via Nix Flake";

  nixConfig.bash-prompt = ''\n\[\033[1;31m\][devShell:\w]\$\[\033[0m\] '';

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
              gcc
              gdb
            ];

            shellHook = ''
              echo -e "\nC/C++ Development Environment via Nix Flake\n"

              echo -e "┌─────────────────────────────────────────┐"
              echo -e "│             Useful Commands             │"
              echo -e "├───────┬─────────────────────────────────┤"
              echo -e "│ Build │ g++ -g -o fileName fileName.cpp │"
              echo -e "│ Run   │ ./fileName                      │"
              echo -e "│ Debug │ gdb -q fileName                 │"
              echo -e "└───────┴─────────────────────────────────┘"
            '';
          };
        }
      );
    };
}
