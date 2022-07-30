{ pkgs, lib, hyraizyn, config, kor, krioniksRev, nixOSRev, ... }:
let
  inherit (lib) mkOverride;

in
{
  boot = {
    supportedFilesystems = mkOverride 10 [ "btrfs" "vfat" "xfs" "ntfs" ];
  };

  isoImage = {
    isoBaseName = "krioniks";
    volumeID = "krioniks-${krioniksRev}-${nixOSRev}-${pkgs.stdenv.hostPlatform.uname.processor}";

    makeUsbBootable = true;
    makeEfiBootable = true;
  };

}
