{
  # in order: Compressor, Pioneer
  # pioneer correction paratially from
  # https://www.hifispecs.com/pioneer-sp-fs52/
  # though i largely corrected the ~70Hz by ear
  output = {
    blocklist = [ ];

    "compressor#0" = {
      attack = 20.0;
      boost-amount = 6.0;
      boost-threshold = -72.0;
      bypass = false;
      dry = -100.0;
      hpf-frequency = 10.0;
      hpf-mode = "off";
      input-gain = 0.0;
      knee = -6.0;
      lpf-frequency = 20000.0;
      lpf-mode = "off";
      makeup = 0.0;
      mode = "Downward";
      output-gain = 4.0;
      ratio = 4.0;
      release = 100.0;
      release-threshold = -100.0;
      sidechain = {
        lookahead = 0.0;
        mode = "RMS";
        preamp = 0.0;
        reactivity = 10.0;
        source = "Middle";
        stereo-split-source = "Left/Right";
        type = "Feed-forward";
      };
      stereo-split = false;
      threshold = -27.500000000000078;
      wet = 0.0;
    };

    "equalizer#0" = {
      balance = 0.0;
      bypass = false;
      input-gain = -7.0;
      left = {
        band0 = {
          frequency = 70.0;
          gain = 7.0;
          mode = "APO (DR)";
          mute = false;
          q = 4.0630998611450195;
          slope = "x1";
          solo = false;
          type = "Bell";
          width = 4.0;
        };
        band1 = {
          frequency = 7000.0;
          gain = 1.0;
          mode = "APO (DR)";
          mute = false;
          q = 1.5;
          slope = "x1";
          solo = false;
          type = "Bell";
          width = 4.0;
        };
      };
      mode = "IIR";
      num-bands = 2;
      output-gain = 0.0;
      pitch-left = 0.0;
      pitch-right = 0.0;
      right = {
        band0 = {
          frequency = 70.0;
          gain = 7.0;
          mode = "APO (DR)";
          mute = false;
          q = 4.0630998611450195;
          slope = "x1";
          solo = false;
          type = "Bell";
          width = 4.0;
        };
        band1 = {
          frequency = 7000.0;
          gain = 1.0;
          mode = "APO (DR)";
          mute = false;
          q = 1.5;
          slope = "x1";
          solo = false;
          type = "Bell";
          width = 4.0;
        };
      };
      split-channels = false;
    };

    plugins_order = [
      "compressor#0"
      "equalizer#0"
    ];
  };
}
