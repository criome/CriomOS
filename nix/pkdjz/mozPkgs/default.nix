{ self, mkPkgs }:

mkPkgs {
  overlays = [ (import (self + /rust-overlay.nix)) ];
}
