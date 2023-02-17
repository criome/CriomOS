{ src, python3Packages, mpv, ffmpeg }:
let
in
python3Packages.buildPythonApplication {
  name = "videocut";

  inherit src;
  version = src.shortRev;

  nativeBuildInputs = with python3Packages;
    [ pyqt5 mpv ffmpeg pillow ];

  buildPhase = ''
    make -C src/ffmpeg/src/ -f makefile5
    make -C src/ffmpeg/src/ -f makefile5 clean
  '';

  installPhase = ''
    mkdir -p $out/share/applications
    mkdir -p $out/bin
    cp build/VideoCut.desktop $out/share/applications
    cp src/VideoCut.py  $out/bin/VideoCut
    chmod +x $out/bin/VideoCut
  '';
}
