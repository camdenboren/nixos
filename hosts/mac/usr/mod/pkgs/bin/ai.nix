{ pkgs, ... }:

{
  # enables usage w/in zed via acp
  home.packages = with pkgs; [
    codex-acp
  ];

  programs.codex = {
    enable = true;
    # waiting on
    # https://github.com/nix-community/home-manager/issues/9397
    /*
      settings = {
      model_reasoning_effort = "xhigh";
      };
    */
  };
}
