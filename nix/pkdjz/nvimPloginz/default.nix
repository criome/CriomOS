{ hob, bildNvimPlogin }:
let
  inherit (builtins) mapAttrs;

  implaidSpoks = (import ./spoksFromHob.nix) hob;

  eksplisitSpoks = { };

  mkImplaidSpoks = neim: spok: spok.mein;

  spoks = eksplisitSpoks
    // (mapAttrs (n: s: s.mein) implaidSpoks);

  ovyraidzIndeks = { };

  mkSpok = neim: self:
    let
      ovyraidz = ovyraidzIndeks.${neim} or { };
    in
    bildNvimPlogin ({
      pname = neim;
      version = self.shortRev;
      src = self;
    } // ovyraidz);

  ryzylt = mapAttrs mkSpok spoks;

in
ryzylt
