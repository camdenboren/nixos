{ inputs, system, ... }:

{
  nixpkgs.overlays = [
    (final: prev: {
      alc-calc = inputs.alc-calc.packages.${system}.default;
      chat-script = inputs.chat-script.packages.${system}.default;
      chatbot-util = inputs.chatbot-util.packages.${system}.default;
      yt-x = inputs.yt-x.packages.${system}.default;
    })
  ];
}
