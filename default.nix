let
  flakeCompat = import ./nix/flake-compat;

in
flakeCompat.defaultNix
