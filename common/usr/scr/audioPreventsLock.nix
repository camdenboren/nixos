{ pkgs }:

# from https://askubuntu.com/questions/1564792/is-there-any-way-to-keep-pc-from-suspending-while-playing-audio
# though I removed `--inhibit suspend` since I just want to prevent the
# screen locking, which is accomplished by the default (equivalent to
# `--inhibit idle`)
pkgs.writeShellScriptBin "audioPreventsLock" ''
  exec 2>/dev/null
  while : ; do
    sleep 1
    if ${pkgs.pulseaudio}/bin/pactl list sinks short | grep -q RUNNING$ ; then
      # We're using sleep 999999 because waitpid $$ doesn't work for @Stygian
      # If you want to log out then back in without rebooting, ensure that
      # only one instance of the sleep process and this script run
      gnome-session-inhibit sleep 999999 &
      pid=$!
      while ${pkgs.pulseaudio}/bin/pactl list sinks short | grep -q RUNNING$ ; do
        sleep 1
      done
      kill -9 "$pid"
    fi
  done
''
