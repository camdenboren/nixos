{ ... }:

{
  home.file = {
    ".hushlogin" = {
      text = "";
    };

    # Lynx config
    ".config/lynx/lynx.cfg" = {
      source = ../../../../../../common/usr/dot/lynx/lynx.cfg;
    };
    ".config/lynx/lynx.lss" = {
      source = ../../../../../../common/usr/dot/lynx/lynx.lss;
    };
  };
}
