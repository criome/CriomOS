{ self, mkPkgs, system }:

mkPkgs {
  inherit system;
  overlays = [ (import (self + /rust-overlay.nix)) ];
}
