{ kor, lib }:

{ types
, methods ? { }
, extraTypecheckingModule ? { }
, extraModuleArgs ? { }
}@spec:

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

  methods = mkLamdyz { klozyr = inputs; lamdyz = specs.methods; };

in
methods // { datom = typeCheckedInputs; }
