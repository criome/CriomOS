{ kor, pkgs, krimyn, uyrld, ... }:
let
  inherit (kor) optionals;
  inherit (krimyn.spinyrz) izNiksDev izSemaDev saizAtList;
  inherit (uyrld.arcnmxNixexprs.legacyPackages.obs-studio-plugins) droidcam-obs;

  niksDevPackages = with pkgs;
    [ pandoc ];

  semaDevPackages = with pkgs;
    [ krita calibre shotcut zoom-us virt-manager ];

  updatedDroidCamObs = droidcam-obs.overrideAttrs (attrs:
    let version = "1.5.1"; in
    {
      inherit version;
      src = pkgs.fetchFromGitHub {
        owner = "dev47apps";
        repo = "droidcam-obs-plugin";
        rev = version;
        sha256 = "9mBITkBbraWv6Z6tDBR2EJQhKabDnOwcrdcBlrsY3Qw=";
      };

      buildInputs = attrs.buildInputs ++
        (with pkgs; [ libimobiledevice.dev ]);

      buildPhase = ''
        runHook preBuild

        $CXX -I src \
          -std=c++11 -DRELEASE=1 \
          src/*.c src/sys/$sysname/*.c \
          $(pkg-config --cflags --libs libobs libavcodec libavformat libavutil libturbojpeg libusbmuxd-2.0 libimobiledevice-1.0) \
          -lobs-frontend-api \
          -shared -o $libname

        runHook postBuild
      '';
    });

in
kor.mkIf saizAtList.max {
  home = {
    packages = with pkgs; [
      # freecad # broken
    ]
    ++ (optionals izNiksDev niksDevPackages)
    ++ (optionals izSemaDev semaDevPackages);
  };

  programs = {
    chromium = {
      enable = true;
      extensions = [
        { id = "cjpalhdlnbpafiamejdnhcphjbkeiagm"; } # ublock origin
        {
          id = "dcpihecpambacapedldabdbpakmachpb";
          updateUrl = "https://raw.githubusercontent.com/iamadamdev/bypass-paywalls-chrome/master/updates.xml";
        }
      ];
    };

    obs-studio = {
      enable = true;
      plugins =
        with pkgs.obs-studio-plugins;
        with uyrld.arcnmxNixexprs.legacyPackages.obs-studio-plugins;
        [ updatedDroidCamObs wlrobs ];
    };

  };
}
