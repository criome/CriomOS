{ kor, pkgs, user, uyrld, pkdjz, ... }:
let
  inherit (kor) optionals;
  inherit (user.spinyrz) izNiksDev izSemaDev saizAtList;

  niksDevPackages = with pkgs;
    [ pandoc ];

  semaDevPackages = with pkgs;
    [ krita calibre virt-manager gimp ];

  allObsPlugins = pkgs.obs-studio-plugins // uyrld.arcnmxNixexprs.legacyPackages.obs-studio-plugins;

in
kor.mkIf saizAtList.max {
  home = {
    packages = with pkgs; [
      # freecad # broken
      wineWowPackages.waylandFull
      whatsapp-for-linux
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
        with allObsPlugins; [
          droidcam-obs
          wlrobs
          pkdjz.obs-ndi
          obs-pipewire-audio-capture
          advanced-scene-switcher
          obs-move-transition
          obs-vaapi
          waveform
        ];
    };

  };

  services = {
    easyeffects = { enable = true; };
  };
}
