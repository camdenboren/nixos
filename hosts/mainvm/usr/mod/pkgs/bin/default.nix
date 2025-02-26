{ ... }:

{
  imports = [
    # Common
    ../../../../../../common/usr/mod/pkgs/bin/basic
    ../../../../../../common/usr/mod/pkgs/bin/coding
    ../../../../../../common/usr/mod/pkgs/bin/engineering
    ../../../../../../common/usr/mod/pkgs/bin/styling

    # Host-specific
    ./scripts.nix
  ];
}
