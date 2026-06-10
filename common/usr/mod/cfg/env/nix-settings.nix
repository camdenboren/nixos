{
  hostname,
  ...
}:

{
  nixpkgs.config = {
    allowUnfree = true;
    allowUnsupportedSystem = hostname == "macvm";
    permittedInsecurePackages = [
      "electron-39.8.10"
    ];
  };
}
