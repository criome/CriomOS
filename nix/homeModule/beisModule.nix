{ kor, lib, krimyn, ... }:
let
  inherit (kor) optional;

in
{
  config = {
    home = {
      username = krimyn.neim;
      homeDirectory = "/home/" + krimyn.neim;
      # TODO
      stateVersion = "23.11";
    };
  };
}
