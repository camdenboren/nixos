{ ... }:

{
  imports = [
    # Common
    # ollama via nixpkgs can't run any models atm
    # checked v9.6, v10.0, and v11.3
    #../../../../../../common/usr/mod/pkgs/srv/utils
  ];
}
