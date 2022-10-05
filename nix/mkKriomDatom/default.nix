{ mkDatom, kor, lib }: kriozonDataInput:
let
  name = "kriozon";

  typeModule = import ./typeModule.nix;

  methods = {
    mkOutputs = import ./mkOutputs.nix;
    nodes = import ./nodes.nix;
  };

in
mkDatom { inherit name typeModule methods; } kriozonDataInput
