{ ... }:

{
  programs.bash = {
    sessionVariables = {
      LYNX_CFG = "~/.config/lynx/lynx.cfg";
      LYNX_LSS = "~/.config/lynx/lynx.lss";
    };
  };
}
