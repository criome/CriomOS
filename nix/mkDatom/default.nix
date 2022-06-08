lib:

{ inputs
, types
, methods
, extraTypecheckingModule ? { }
, extraModuleArgs ? { }
}:


let
  argsModule = { config._module.args = extraModuleArgs // { inherit lib; }; };

  typeCheckingModule = { ... }: {
    options = { inputs = types; };
    config.inputs = inputs;
  };

  typeCheckingEvaluation = evalModules {
    modules = [ argsModule typeCheckingModule extraTypecheckingModule ];
  };

  typeCheckedInput = typeCheckingEvaluation.config.inputs;

  mkMethod = name: value: { };

in
{
  datom = typeCheckedInput;
  methods = mapAttrs mkMethod methods;
}
