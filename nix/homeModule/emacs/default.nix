{ pkgs, pkdjz, user, crioZone, profile, ... }:
let
  inherit (pkdjz) meikImaks slynkPackages;
  package = meikImaks { inherit user profile; };

  slynkPkgs = with slynkPackages; [
    slynk # slynk-asdf slynk-quicklisp slynk-macrostep
  ];

in
{
  home = {
    packages = [ package ]
      ++ (with pkgs; [ nil ])
      ++ slynkPkgs;

    sessionVariables = {
      EDITOR = "emacsclient -c";
    };
  };

  services = {
    emacs = {
      enable = true;
      inherit package;
      startWithUserSession = "graphical";
    };
  };
}
