{ pkgs, ... }:

{
  # Enables support for Bluetooth
  hardware.bluetooth.enable = true;

  # Bluetooth driver for ASUS USB-BT500 chip (RTL8761b)
  hardware.firmware = with pkgs; [
    rtl8761b-firmware
  ];
}
