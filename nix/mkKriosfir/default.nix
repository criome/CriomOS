{ kor, lib, uncheckedKriosfirProposal }:
let
  inherit (lib) evalModules;

  PriMetastriz = uncheckedKriosfirProposal;

  argzModule = {
    config = {
      inherit PriMetastriz;
      _module.args = {
        inherit kor lib;
      };
    };
  };

  metastrizModule = import ./metastrizModule.nix;
  spicizModule = import ./spicizModule.nix;

  ivaliueicyn = evalModules {
    modules = [
      argzModule
      metastrizModule
      spicizModule
    ];
  };

in
{
  inherit (ivaliueicyn.config) spiciz;
  datom = ivaliueicyn.config.Metastriz;
}
