{ ... }:

{
  home.file = {
    ".hushlogin" = {
      text = "";
    };

    ".config/AutoRaise/config" = {
      source = ../../../dot/AutoRaise/config;
    };
  };
}
