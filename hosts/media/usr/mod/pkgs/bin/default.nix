{ ... }:

{
  imports = [
    # Common
    ../../../../../../common/usr/mod/pkgs/bin/basic
    ../../../../../../common/usr/mod/pkgs/bin/coding
    ../../../../../../common/usr/mod/pkgs/bin/content
    ../../../../../../common/usr/mod/pkgs/bin/gaming
    ../../../../../../common/usr/mod/pkgs/bin/styling
    ../../../../../../common/usr/mod/pkgs/bin/utils

    # Host-specific
    ./scripts.nix
  ];
}
