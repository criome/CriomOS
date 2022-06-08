{ kor, lib }:

{ types
, methods ? { }
, extraTypecheckingModule ? { }
, extraModuleArgs ? { }
}:

inputs:

let
  inherit (kor) mkLamdyz;
  inherit (lib) evalModules;

  argsModule = { config._module.args = extraModuleArgs // { inherit lib; }; };

  typeCheckingModule = { ... }: {
    options = { inputs = types; };
    config.inputs = inputs;
  };

  typeCheckingEvaluation = evalModules {
    modules = [ argsModule typeCheckingModule extraTypecheckingModule ];
  };

  typeCheckedInputs = typeCheckingEvaluation.config.inputs;

in
{
  datom = typeCheckedInputs;
  methods = mkLamdyz { klozyr = inputs; lamdyz = methods; };
}
