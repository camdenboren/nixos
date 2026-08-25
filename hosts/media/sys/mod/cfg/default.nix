{ ... }:

{
  imports = [
    # Common
    ../../../../../common/sys/mod/cfg/def
    ../../../../../common/sys/mod/cfg/env

    # Host-specific
    ./hw
  ];
}
