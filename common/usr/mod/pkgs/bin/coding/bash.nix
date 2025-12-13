{
  lib,
  hostname,
  system,
  ...
}:

let
  isDarwin = lib.hasSuffix "-darwin" system;
  isVM = lib.hasSuffix "vm" hostname;
  shlvl = if isDarwin then "2" else "1";
in
{
  programs.bash = {
    enable = true;

    # a nix config workflow is included:
    #
    #   cdf - cd into $NH_FLAKE
    #   repl - enter nix repl with nixpkgs
    #   fmt - format all nix files in $NH_FLAKE
    #   check - evaluate $NH_FLAKE for all hosts
    #   clean - remove unused nix store roots
    #   lgf - open lazygit in $NH_FLAKE
    #   update - update $NH_FLAKE's inputs
    #   bld - build a derivation in cwd
    #   sw - rebuild system

    shellAliases = {
      bld = "nix-build -E 'with import <nixpkgs> {}; callPackage ./default.nix {}'";
      c = "cd ~ && clear";
      cdf = "cd $NH_FLAKE";
      cdh = "cd ~";
      cdr = "cd ~/Documents/Repos";
      cdt = "cd ~/Documents/Tests";
      check = "nix flake check $NH_FLAKE";
      clean = if (isDarwin || isVM) then "nh clean all" else "nh clean all -k 2";
      ddg = "lynx -vikeys start.duckduckgo.com/lite/";
      fmt = "fd -t f -e nix . $NH_FLAKE -x nixfmt '{}'";
      lg = "lazygit";
      lgf = "lazygit -p $NH_FLAKE";
      ls = "ls -a";
      lsg = "ls | grep";
      repl = "nix repl -f '<nixpkgs>'";
      sw = if isDarwin then "nh darwin switch" else "nh os switch";
      tr = if isDarwin then "trash" else "gio trash";
      update = "nix flake update --flake $NH_FLAKE";
      zed =
        lib.optionalString isVM (
          "ZED_ALLOW_EMULATED_GPU=1 " + lib.optionalString (hostname == "macvm") ''WAYLAND_DISPLAY="" ''
        )
        + "zeditor";
      ":q" = "exit";
    }
    // (
      if (hostname == "main") then
        {
          nixos = "quickemu --vm ~/vm/nixos-24.05-gnome.conf --status-quo";
          ubuntu = "quickemu --vm ~/vm/ubuntu-24.04.conf --status-quo";
          windows = "quickemu --vm ~/vm/windows-11.conf --display gtk --status-quo";
        }
      else
        { }
    );

    initExtra = ''
      if (( SHLVL > ${shlvl} )); then
        export PS1="\n\[\033[1;31m\][shell:\w]\$\[\033[0m\] "
      fi

      mkcd () {
        mkdir $1
        cd $1
      }

      run () {
        nix run nixpkgs#$1
      }

      shell () {
        NIXPKGS_STRING=""
        for var in "$@"
        do
          VAR_STRING="nixpkgs#''${var} "
          NIXPKGS_STRING+=$VAR_STRING
        done
        nix shell $NIXPKGS_STRING
      }
    '';
  };
}
