{
  # in order: HFControlL, HFControlR (disabled), KEF, AKG (disabled)
  output = {
    blocklist = [ ];

    "equalizer#0" = {
      balance = 0.0;
      bypass = false;
      input-gain = 0.0;
      left = {
        band0 = {
          frequency = 11600.0;
          gain = -3.0;
          mode = "APO (DR)";
          mute = false;
          q = 10.0;
          slope = "x1";
          solo = false;
          type = "Bell";
          width = 4.0;
        };
        band1 = {
          frequency = 12000.0;
          gain = 0.0;
          mode = "APO (DR)";
          mute = false;
          q = 0.7635999917984009;
          slope = "x1";
          solo = false;
          type = "Lo-pass";
          width = 4.0;
        };
        band2 = {
          frequency = 12500.0;
          gain = -7.0;
          mode = "APO (DR)";
          mute = false;
          q = 10.0;
          slope = "x1";
          solo = false;
          type = "Bell";
          width = 4.0;
        };
        band3 = {
          frequency = 12900.0;
          gain = -5.0;
          mode = "APO (DR)";
          mute = false;
          q = 10.0;
          slope = "x1";
          solo = false;
          type = "Bell";
          width = 4.0;
        };
        band4 = {
          frequency = 13300.0;
          gain = -7.0;
          mode = "APO (DR)";
          mute = false;
          q = 10.0;
          slope = "x1";
          solo = false;
          type = "Bell";
          width = 4.0;
        };
        band5 = {
          frequency = 13800.0;
          gain = -8.0;
          mode = "APO (DR)";
          mute = false;
          q = 10.0;
          slope = "x1";
          solo = false;
          type = "Bell";
          width = 4.0;
        };
        band6 = {
          frequency = 14000.0;
          gain = -5.0;
          mode = "APO (DR)";
          mute = false;
          q = 10.0;
          slope = "x1";
          solo = false;
          type = "Bell";
          width = 4.0;
        };
        band7 = {
          frequency = 14400.0;
          gain = -7.0;
          mode = "APO (DR)";
          mute = false;
          q = 10.0;
          slope = "x1";
          solo = false;
          type = "Bell";
          width = 4.0;
        };
        band8 = {
          frequency = 15000.0;
          gain = -6.0;
          mode = "APO (DR)";
          mute = false;
          q = 4.860000133514404;
          slope = "x1";
          solo = false;
          type = "Bell";
          width = 4.0;
        };
      };
      mode = "IIR";
      num-bands = 9;
      output-gain = 0.0;
      pitch-left = 0.0;
      pitch-right = 0.0;
      right = {
        band0 = {
          frequency = 11600.0;
          gain = -3.0;
          mode = "APO (DR)";
          mute = true;
          q = 10.0;
          slope = "x1";
          solo = false;
          type = "Bell";
          width = 4.0;
        };
        band1 = {
          frequency = 12000.0;
          gain = 0.0;
          mode = "APO (DR)";
          mute = true;
          q = 0.7635999917984009;
          slope = "x1";
          solo = false;
          type = "Lo-pass";
          width = 4.0;
        };
        band2 = {
          frequency = 12500.0;
          gain = -7.0;
          mode = "APO (DR)";
          mute = true;
          q = 10.0;
          slope = "x1";
          solo = false;
          type = "Bell";
          width = 4.0;
        };
        band3 = {
          frequency = 12900.0;
          gain = -5.0;
          mode = "APO (DR)";
          mute = true;
          q = 10.0;
          slope = "x1";
          solo = false;
          type = "Bell";
          width = 4.0;
        };
        band4 = {
          frequency = 13300.0;
          gain = -7.0;
          mode = "APO (DR)";
          mute = true;
          q = 10.0;
          slope = "x1";
          solo = false;
          type = "Bell";
          width = 4.0;
        };
        band5 = {
          frequency = 13800.0;
          gain = -8.0;
          mode = "APO (DR)";
          mute = true;
          q = 10.0;
          slope = "x1";
          solo = false;
          type = "Bell";
          width = 4.0;
        };
        band6 = {
          frequency = 14000.0;
          gain = -5.0;
          mode = "APO (DR)";
          mute = true;
          q = 10.0;
          slope = "x1";
          solo = false;
          type = "Bell";
          width = 4.0;
        };
        band7 = {
          frequency = 14400.0;
          gain = -7.0;
          mode = "APO (DR)";
          mute = true;
          q = 10.0;
          slope = "x1";
          solo = false;
          type = "Bell";
          width = 4.0;
        };
        band8 = {
          frequency = 15000.0;
          gain = -6.0;
          mode = "APO (DR)";
          mute = true;
          q = 4.860000133514404;
          slope = "x1";
          solo = false;
          type = "Bell";
          width = 4.0;
        };
      };
      split-channels = true;
    };

    "equalizer#1" = {
      balance = 0.0;
      bypass = true;
      input-gain = 0.0;
      left = {
        band0 = {
          frequency = 11700.0;
          gain = -8.0;
          mode = "APO (DR)";
          mute = true;
          q = 5.900000095367432;
          slope = "x1";
          solo = false;
          type = "Bell";
          width = 4.0;
        };
        band1 = {
          frequency = 13700.0;
          gain = 9.699999809265137;
          mode = "APO (DR)";
          mute = true;
          q = 0.8181999921798706;
          slope = "x1";
          solo = false;
          type = "Hi-shelf";
          width = 4.0;
        };
        band2 = {
          frequency = 14000.0;
          gain = 9.0;
          mode = "APO (DR)";
          mute = true;
          q = 0.6666666865348816;
          slope = "x1";
          solo = false;
          type = "Hi-shelf";
          width = 4.0;
        };
      };
      mode = "IIR";
      num-bands = 3;
      output-gain = 0.0;
      pitch-left = 0.0;
      pitch-right = 0.0;
      right = {
        band0 = {
          frequency = 11700.0;
          gain = -8.0;
          mode = "APO (DR)";
          mute = false;
          q = 5.900000095367432;
          slope = "x1";
          solo = false;
          type = "Bell";
          width = 4.0;
        };
        band1 = {
          frequency = 13700.0;
          gain = 9.699999809265137;
          mode = "APO (DR)";
          mute = false;
          q = 0.8181999921798706;
          slope = "x1";
          solo = false;
          type = "Hi-shelf";
          width = 4.0;
        };
        band2 = {
          frequency = 14000.0;
          gain = 9.0;
          mode = "APO (DR)";
          mute = false;
          q = 0.6666666865348816;
          slope = "x1";
          solo = false;
          type = "Hi-shelf";
          width = 4.0;
        };
      };
      split-channels = true;
    };

    "equalizer#2" = {
      balance = 0.0;
      bypass = false;
      input-gain = 0.0;
      left = {
        band0 = {
          frequency = 85.0;
          gain = 12.0;
          mode = "APO (DR)";
          mute = false;
          q = 4.36;
          slope = "x1";
          solo = false;
          type = "Bell";
          width = 4.0;
        };
        band1 = {
          frequency = 110.0;
          gain = -18.0;
          mode = "APO (DR)";
          mute = false;
          q = 4.36;
          slope = "x1";
          solo = false;
          type = "Bell";
          width = 4.0;
        };
        band2 = {
          frequency = 2000.0;
          gain = 2.5;
          mode = "APO (DR)";
          mute = false;
          q = 4.36;
          slope = "x1";
          solo = false;
          type = "Bell";
          width = 4.0;
        };
      };
      mode = "IIR";
      num-bands = 3;
      output-gain = -11.0;
      pitch-left = 0.0;
      pitch-right = 0.0;
      right = {
        band0 = {
          frequency = 85.0;
          gain = 12.0;
          mode = "APO (DR)";
          mute = false;
          q = 4.36;
          slope = "x1";
          solo = false;
          type = "Bell";
          width = 4.0;
        };
        band1 = {
          frequency = 110.0;
          gain = -18.0;
          mode = "APO (DR)";
          mute = false;
          q = 4.36;
          slope = "x1";
          solo = false;
          type = "Bell";
          width = 4.0;
        };
        band2 = {
          frequency = 2000.0;
          gain = 2.5;
          mode = "APO (DR)";
          mute = false;
          q = 4.36;
          slope = "x1";
          solo = false;
          type = "Bell";
          width = 4.0;
        };
      };
      split-channels = false;
    };

    "equalizer#3" = {
      balance = 0.0;
      bypass = true;
      input-gain = -4.5;
      left = {
        band0 = {
          frequency = 2200.0;
          gain = 1.5;
          mode = "APO (DR)";
          mute = false;
          q = 1.0;
          slope = "x1";
          solo = false;
          type = "Bell";
          width = 4.0;
        };
        band1 = {
          frequency = 3915.0;
          gain = 4.0;
          mode = "APO (DR)";
          mute = false;
          q = 4.0;
          slope = "x1";
          solo = false;
          type = "Bell";
          width = 4.0;
        };
        band2 = {
          frequency = 6800.0;
          gain = -3.0;
          mode = "APO (DR)";
          mute = false;
          q = 4.0;
          slope = "x1";
          solo = false;
          type = "Bell";
          width = 4.0;
        };
      };
      mode = "IIR";
      num-bands = 3;
      output-gain = 0.0;
      pitch-left = 0.0;
      pitch-right = 0.0;
      right = {
        band0 = {
          frequency = 2200.0;
          gain = 1.5;
          mode = "APO (DR)";
          mute = false;
          q = 1.0;
          slope = "x1";
          solo = false;
          type = "Bell";
          width = 4.0;
        };
        band1 = {
          frequency = 3915.0;
          gain = 4.0;
          mode = "APO (DR)";
          mute = false;
          q = 4.0;
          slope = "x1";
          solo = false;
          type = "Bell";
          width = 4.0;
        };
        band2 = {
          frequency = 6800.0;
          gain = -3.0;
          mode = "APO (DR)";
          mute = false;
          q = 4.0;
          slope = "x1";
          solo = false;
          type = "Bell";
          width = 4.0;
        };
      };
      split-channels = false;
    };

    plugins_order = [
      "equalizer#0"
      "equalizer#1"
      "equalizer#2"
      "equalizer#3"
    ];
  };
}
