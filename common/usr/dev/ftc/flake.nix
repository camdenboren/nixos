{
  description = "FTC Development Environment via Nix Flake";

  inputs = {
    nixpkgs = {
      url = "github:nixos/nixpkgs/nixos-unstable";
    };
    android-nixpkgs = {
      url = "github:tadfisher/android-nixpkgs";

      # The main branch follows the "canary" channel of the Android SDK
      # repository. Use another android-nixpkgs branch to explicitly
      # track an SDK release channel.
      #
      # .../android-nixpkgs/stable, beta, preview, canary";

      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      android-nixpkgs,
      ...
    }:
    let
      supportedSystems = [
        "x86_64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];
      forEachSupportedSystem =
        function:
        nixpkgs.lib.genAttrs supportedSystems (
          system:
          function {
            pkgs = nixpkgs.legacyPackages.${system};
            android-sdk = android-nixpkgs.sdk.${system} (
              sdkPkgs:
              with sdkPkgs;
              [
                # Useful packages for building and testing.
                build-tools-30-0-3
                cmdline-tools-latest
                platform-tools
                platforms-android-29

                # Other useful packages for a development environment.
                # emulator
                # ndk-26-1-10909125
                # skiaparser-3
                # sources-android-34
              ]
              ++ nixpkgs.lib.optionals (system == "x86_64-darwin" || system == "x86_64-linux") [
                # system-images-android-29-google-apis-x86-64
                # system-images-android-29-google-apis-playstore-x86-64
              ]
              ++ nixpkgs.lib.optionals (system == "aarch64-darwin") [
                # system-images-android-29-google-apis-arm64-v8a
                # system-images-android-29-google-apis-playstore-arm64-v8a
              ]
            );
          }
        );
    in
    {
      devShells = forEachSupportedSystem (
        { pkgs, android-sdk }:
        {
          default = pkgs.mkShell {
            packages =
              [
                android-sdk
              ]
              ++ (with pkgs; [
                bashInteractive
                jdk17
                aapt
              ]);

            # override aapt2 binary w/ nixpkgs'
            GRADLE_OPTS = "-Dorg.gradle.project.android.aapt2FromMavenOverride=${pkgs.aapt}/bin/aapt2";

            shellHook = ''
              export PS1="\n\[\033[1;31m\][devShell:\w]\$\[\033[0m\] "
              echo -e "\nFTC Development Environment via Nix Flake\n"
              echo -e "Build app: ./gradlew build"
              echo -e "Uninstall app: adb -d uninstall com.qualcomm.ftcrobotcontroller"
              echo -e "Install app: adb -d install ./TeamCode/build/outputs/apk/release/TeamCode-release.apk\n"
              if ! test -d ./FtcRobotController; then 
                echo -e "Fetching FTC SDK..." && git clone https://github.com/FIRST-Tech-Challenge/FtcRobotController.git && echo ""
              fi
              java --version && echo ""
              adb --version && echo ""
              codium FtcRobotController
            '';

            # prints emu. info and cmds if desired (system images not available for aarch64-darwin)
            # echo -e "Useful commands:\nAdd avd: avdmanager create avd -n test -k \"system-images;android-34;google_apis;x86_64\""
            # echo -e "List emulators: emulator -list-avds"
            # echo -e "Run emulator: emulator -avd test -no-metrics"
            # echo -e "Run stateless emulator (allows for 2+ as well): postfix -read-only"
            # emulator -version | sed '1d;2d;6d;7d;8d;9d;10d;11d;12d;13d;14d;'
          };
        }
      );
    };
}
