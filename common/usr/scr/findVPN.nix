{ pkgs }:

pkgs.writeShellScriptBin "findVPN" ''
  # vars for functionality
  notConnected=1
  countries=("al" "au" "at" "be" "br" "bg" "ca" "cl" "co" "hr" "cy" "cz" "dk" "ee" "fi" "fr" "de" "gr" "hk" "hu" "id" "ie" "il" "it" "jp" "mx" "nl" "nz" "ng" "no" "pe" "ph" "pl" "pt" "ro" "rs" "sg" "sk" "si" "za" "es" "se" "ch" "th" "tr" "gb" "ua" "us")

  # vars, functions for formatting
  log="Command Log:"
  box() { ${pkgs.boxes}/bin/boxes -d ansi -s $(tput cols); }

  # switch to sweden VPN - little overlap between yt-dlp <-> freetube in US
  sleep 0.1
  echo -e "\n\033[1;33mConnecting to a different VPN...\033[0m\n"
  mullvad relay set location "se" 2> /dev/null | box
  sleep 2

  # main logic
  while (( notConnected )); do
    echo -e "\n\033[1;33mAttempting to dry-download video...\033[0m\n"
    echo -e $log
    set -o pipefail
    ${pkgs.yt-dlp}/bin/yt-dlp -s https://youtu.be/mQCoWgW_s7Q 2> /dev/null | box
    if [ $? -eq 0 ]; then
      echo -e "\n\033[1;32mSuccessfully dry-downloaded video.\033[0m\n"
      notConnected=0
    else
      echo -e "\n\033[1;31mDry-download failed. Connecting to a different VPN...\033[0m\n"
      echo -e $log
      num=$(($RANDOM % 48))
      mullvad relay set location "''${countries[$num]}" 2> /dev/null | box
      sleep 2
    fi
  done

  # ask for user input before exiting when run from .desktop
  if (( SHLVL == 1 )); then
    read -n 1 -s -r -p "Press any key to continue..."
  fi
''
