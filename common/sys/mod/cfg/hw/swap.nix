{ hostname, ... }:

let
  gb = if (hostname == "main") then 32 else 8;
in
{
  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = gb * 1024;
    }
  ];
}
