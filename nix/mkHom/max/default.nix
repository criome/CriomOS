{ kor, pkgs, krimyn, ... }:
let
  inherit (kor) optionals;
  inherit (krimyn.spinyrz) izNiksDev izSemaDev;

  niksDevPackages = with pkgs; [
  ];

  semaDevPackages = with pkgs; [
    krita
    calibre
    pandoc
  ];

in
{
  imports = [ ./firefox.nix ];

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
  };
}
