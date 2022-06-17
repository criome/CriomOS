hob:

let
  pkdjz = {
    aski = {
      lamdy = import ./aski;
      modz = [ "uyrld" "pkgs" "pkdjz" ];
      self = null;
    };

    beaker = {
      lamdy = import ./beaker;
      modz = [ "pkgs" ];
      self = null;
    };

    bildNvimPlogin = {
      lamdy = import ./bildNvimPlogin;
      modz = [ "pkgs" "pkdjz" ];
      self = null;
    };

    crate2nix = {
      lamdy = import ./crate2nix;
      modz = [ "pkdjz" ];
    };

    deryveicyn = {
      lamdy = import ./deryveicyn;
      modz = [ "pkgs" "uyrld" "pkdjz" ];
      self = null;
    };

    dunst = {
      lamdy = import ./dunst;
      modz = [ "pkgs" ];
    };

    ementEl = {
      lamdy = import ./ement-el;
      modz = [ "pkgs" ];
    };

    fetchPijul = {
      lamdy = import ./fetchPijul;
      modz = [ "pkgs" ];
    };

    guix = {
      lamdy = import ./guix;
      modz = [ "lib" "pkgs" "hob" ];
    };

    home-manager = {
      lamdy = import ./home-manager;
      modz = [ "lib" "pkgs" "hob" ];
    };

    ivalNixos = {
      lamdy = import ./ivalNixos;
      modz = [ "lib" "pkgsSet" ];
      self = hob.nixpkgs;
    };

    kreitOvyraidz = {
      lamdy = import ./kreitOvyraidz;
      modz = [ "pkgs" "lib" ];
      self = null;
    };

    kynvyrt = {
      lamdy = import ./kynvyrt;
      modz = [ "pkgs" "uyrld" ];
      self = null;
    };

    lib = {
      lamdy = import ./lib;
      modz = [ ];
      self = hob.nixpkgs;
    };

    librem5-flash-image = {
      lamdy = import ./librem5/flashImage.nix;
      modz = [ "pkgs" ];
    };

    mach-nix = { lamdy = import ./mach-nix; };

    meikPkgs = {
      lamdy = import ./meikPkgs;
      modz = [ "lib" ];
      self = hob.nixpkgs;
    };

    meikImaks = {
      lamdy = import ./meikImaks;
      modz = [ "pkdjz" "hob" ];
      self = hob.emacs-overlay;
    };

    mfgtools = {
      lamdy = import ./mfgtools;
      modz = [ "pkgs" ];
    };

    mkCargoNix = {
      lamdy = import ./mkCargoNix;
      modz = [ "pkgs" "pkgsSet" "lib" "pkdjz" ];
      self = null;
    };

    mkWebpage = {
      lamdy = import ./mkWebpage;
      modz = [ "pkgs" "lib" "pkdjz" ];
    };

    mozPkgs = {
      lamdy = import ./mozPkgs;
      modz = [ "pkdjz" ];
      self = hob.nixpkgs-mozilla;
    };

    naersk = {
      lamdy = import ./naersk;
      modz = [ "pkgs" ];
    };

    nvimLuaPloginz = {
      lamdy = import ./nvimPloginz/lua.nix;
      modz = [ "hob" "pkdjz" ];
      self = null;
    };

    nvimPloginz = {
      lamdy = import ./nvimPloginz;
      modz = [ "hob" "pkdjz" ];
      self = null;
    };

    nerd-fonts = {
      lamdy = import ./nerd-fonts;
      modz = [ "pkgs" ];
      self = null;
    };

    nightlyRust = {
      lamdy = import ./nightlyRust;
      modz = [ "pkdjz" ];
      self = null;
    };

    nix = { lamdy = import ./nix; };

    nix-dev = {
      lamdy = import ./nix;
      modz = [ "pkgs" "pkdjz" ];
      self = hob.nix.maisiliym.dev;
    };

    pkgsNvimPloginz = {
      lamdy = import ./pkgsNvimPloginz;
      modz = [ "pkgsSet" "lib" "pkdjz" ];
      self = hob.nixpkgs;
    };

    ql2nix = {
      lamdy = import ./ql2nix;
      modz = [ "pkgsSet" ];
    };

    staticSbcl = {
      lamdy = import ./sbcl/static.nix;
      modz = [ "pkgsSet" "pkgsStatic" ];
    };

    shen-bootstrap = {
      lamdy = import ./shen/bootstrap.nix;
      modz = [ "pkgs" ];
      self = hob.shen;
    };

    shen-ecl-bootstrap = {
      lamdy = import ./shen/ecl.nix;
      modz = [ "pkgs" ];
      self = null;
    };

    shenPrelude = {
      lamdy = import ./shen/prelude.nix;
      modz = [ "pkgs" ];
    };

    slynkPackages = {
      lamdy = import ./slynkPackages;
      modz = [ "pkgs" ];
      self = null;
    };

    niks = {
      lamdy = import ./niks;
      modz = [ "pkgs" "pkdjz" ];
    };

    vimPloginz = {
      lamdy = import ./vimPloginz;
      modz = [ "pkgs" "pkdjz" "hob" ];
      self = null;
    };
  };

  aliases = {
    shen = pkdjz.shen-ecl-bootstrap;
  };

  adHoc = (import ./adHoc.nix) hob;

in
adHoc // pkdjz // aliases
