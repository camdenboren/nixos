{ pkgs }:

pkgs.writeShellScriptBin "refreshPlugins" ''
  oldPath=$(yabridgectl list)
  echo "Removing old store location..."
  yabridgectl rm $oldPath
  echo "Syncing..."
  yabridgectl sync
  echo -e "\nCalling installPlugins...\n"
  installPlugins
''
