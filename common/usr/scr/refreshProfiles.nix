{ pkgs }:

pkgs.writeShellScriptBin "refreshProfiles" ''
  echo "Renaming old profiles.db..."
  mv ~/Documents/Repos/Notes/Media/Video/FreeTube/profiles.db ~/Documents/Repos/Notes/Media/Video/FreeTube/profiles.db.backup
  echo "Copying new profiles.db..."
  cp ~/.config/FreeTube/profiles.db ~/Documents/Repos/Notes/Media/Video/FreeTube/profiles.db
  echo -e "Removing old profiles.db..."
  rm ~/Documents/Repos/Notes/Media/Video/FreeTube/profiles.db.backup
''
