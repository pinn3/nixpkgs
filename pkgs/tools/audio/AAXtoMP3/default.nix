{ fetchFromGitHub, writeScriptBin, lib, symlinkJoin
, ffmpeg, lame, gnugrep, gnused, findutils, jq, mp4v2, mediainfo
}:

let
  src = fetchFromGitHub {
    owner = "KrumpetPirate";
    repo = "AAXtoMP3";
    rev = "v1.3";
    sha256 = "sha256-7a9ZVvobWH/gPxa3cFiPL+vlu8h1Dxtcq0trm3HzlQg=";
  };
  runtimeInputs = [ ffmpeg lame gnugrep gnused findutils jq mp4v2 mediainfo ];
  AAXtoMP3 = writeScriptBin "AAXtoMP3" ''
    export PATH="${lib.makeBinPath runtimeInputs}:$PATH"
    ${lib.strings.removePrefix ''
      #!/usr/bin/env bash
    '' (builtins.readFile "${src}/AAXtoMP3")}
  '';
in symlinkJoin {
  name = "AAXtoMP3";

  paths = [
    AAXtoMP3
    (writeScriptBin "interactiveAAXtoMP3" ''
      export PATH="${lib.makeBinPath runtimeInputs}:$PATH"
        ${
          lib.strings.removePrefix ''
            #!/usr/bin/env bash
          '' (builtins.replaceStrings [ "./AAXtoMP3" ]
            [ "${AAXtoMP3}/bin/AAXtoMP3" ]
            (builtins.readFile "${src}/interactiveAAXtoMP3"))
        }
    '')
  ];

  meta = {
    homepage = "https://krumpetpirate.github.io/AAXtoMP3";
    description = "Convert Audible's .aax filetype to MP3, FLAC, M4A, or OPUS";
    license = lib.licenses.wtfpl;
  };
}
