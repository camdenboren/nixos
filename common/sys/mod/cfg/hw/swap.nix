{ hostname, ... }:

let
  gb =
    if (hostname == "main") then
      32
    else if (hostname == "media") then
      16
    else
      4;
in
{
  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = gb * 1024;
    }
  ];
}
