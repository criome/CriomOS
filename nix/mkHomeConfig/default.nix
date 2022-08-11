world@{ lib, src, pkgs, kor, uyrld, nextPkgs }:
{ kriozon, krimyn, profile }:
let
  inherit (kor) optional;
  inherit (uyrld) pkdjz;
  inherit (krimyn) stail;
  inherit (krimyn.spinyrz) saizAtList;

  mkHomeManagerModules = import (src + /modules/modules.nix);
  extendedLib = import (src + /modules/lib/stdlib-extended.nix) lib;
  inherit (extendedLib) evalModules;

  homeManagerModules = mkHomeManagerModules {
    inherit pkgs;
    lib = extendedLib;
    useNixpkgsModule = false;
  };

  beisModule = import ./beisModule.nix;

  stailModule =
    if (stail == "emacs")
    then (import ./emacs) else (import ./neovim);

  homModules = [ beisModule ]
    ++ (optional saizAtList.min (import ./min))
    ++ (optional saizAtList.med (import ./med))
    ++ (optional saizAtList.max (import ./max));

  argzModule = {
    home.stateVersion = lib.trivial.release;
    _module.args = {
      inherit pkgs kor pkdjz uyrld
        krimyn kriozon profile nextPkgs;
      hyraizyn = kriozon;
    };
  };

  modules = homModules ++ homeManagerModules
    ++ [ argzModule stailModule ];

  evaluation = evalModules {
    inherit modules;
  };

in
evaluation.config
