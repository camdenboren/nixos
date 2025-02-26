{
  hostname,
  ...
}:

{
  nixpkgs.config = {
    allowUnfree = true;
    allowUnsupportedSystem = (hostname == "macvm");
  };
}
