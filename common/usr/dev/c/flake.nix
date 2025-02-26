{
  description = "C/C++ Development Environment via Nix Flake";

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
              gcc
              gdb
            ];

            shellHook = ''
              export PS1="\n\[\033[1;31m\][devShell:\w]\$\[\033[0m\] "
              echo -e "\nC/C++ Development Environment via Nix Flake\n"
              echo "Build: g++ -g -o filename fileName.cpp"
              echo "Run: ./fileName" 
              echo "Debug: gdb -q fileName"
              echo -e "Helpful gdb cmds:\n  r (run)\n  q (quit)\n  c (continue)\n  b # (bp @ line #)\n  b main (bp @ main)\n  disable b (disable bp's)\n  i b (bp info)\n  clear main (clears bp's in main)\n  n (next)\n  p varName (print varName)\n"
              gcc --version
              gdb --version
            '';
          };
        }
      );
    };
}
