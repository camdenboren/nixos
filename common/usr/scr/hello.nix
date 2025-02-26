{ pkgs }:

pkgs.writeShellScriptBin "hello" ''
  echo "hello world" | ${pkgs.cowsay}/bin/cowsay | ${pkgs.lolcat}/bin/lolcat
''
