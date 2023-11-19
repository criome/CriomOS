args@
{ nixpkgs
, system ? localSystem.system
, localSystem ? { system = args.system; }
, crossSystem ? localSystem
, lib ? import (nixpkgs + /lib)
, overlays ? [ ]
, config ? { allowUnfree = true; }
}:
let
  # Note: somehow, `removeAttrs system args` doesnt work here.
  pkgsTopLevelArguments = { inherit localSystem crossSystem lib overlays config; };
  mkPkgsFn = import (nixpkgs + /pkgs/top-level);

in
# If `localSystem` was explicitly passed, legacy `system` should
  # not be passed, and vice-versa.
assert args ? localSystem -> !(args ? system);
assert args ? system -> !(args ? localSystem);

mkPkgsFn pkgsTopLevelArguments
