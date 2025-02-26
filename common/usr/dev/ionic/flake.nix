{
  description = "Ionic Development Environment via Nix Flake";

  inputs = {
    nixpkgs = {
      url = "github:nixos/nixpkgs/nixos-unstable";
    };
  };

  outputs =
    { nixpkgs, ... }:
    let
      name = "app"; # change app name
      template = "blank"; # choose template
      framework = "vue"; # select framework
      ionic-version = "7.2.0"; # select iconic ver
      native-version = "2.0.1"; # select native-run ver

      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];
      forEachSupportedSystem =
        function:
        nixpkgs.lib.genAttrs supportedSystems (
          system:
          function {
            pkgs = nixpkgs.legacyPackages.${system};
          }
        );
    in
    {
      devShells = forEachSupportedSystem (
        { pkgs }:
        {
          default = pkgs.mkShell {
            packages = with pkgs; [
              bashInteractive
              nodejs
            ];

            shellHook = ''
              export PS1="\n\[\033[1;31m\][devShell:\w]\$\[\033[0m\] "
              echo -e "\nIonic Development Environment via Nix Flake\n"
              echo -e "Serve app: npm run start\n"

              if ! test -d node_modules; then
                if ! test -f package.json; then
                  echo -e "Creating package.json..."
                  echo "{
                    \"scripts\": {
                        \"create\": \"ionic start ${name} ${template} --type ${framework}\"
                    },
                    \"dependencies\": {
                        \"@ionic/cli\": \"^${ionic-version}\",
                        \"native-run\": \"^${native-version}\"
                    }
                }" >> package.json

                  npm install

                  echo -e "Creating app..."
                  npm run create

                  echo -e "Adding script..."
                  sed -i 's/"scripts": {/"scripts": {\n    "start": "ionic serve --port 8000",/g' ./${name}/package.json
                  
                  echo -e "Adding deps..."
                  sed -i 's/"dependencies": {/"dependencies": {\n    "native-run": "^${native-version}",/g' ./${name}/package.json 
                  sed -i 's|"dependencies": {|"dependencies": {\n    "@ionic/cli": "^${ionic-version}",|g' ./${name}/package.json

                  echo -e "Removing old files..."
                  rm -r node_modules
                  rm -f package-lock.json
                  rm -f package.json
                  
                  cd ${name}
                  npm install

                  echo -e "Removing .git..."
                  rm -rf .git
                  cd ..

                  mv ./${name}/{.,}* .
                  rm -r ${name}
                else
                  npm install
                fi
              fi
            '';
          };
        }
      );
    };
}
