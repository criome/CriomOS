{ pkgs, lib, hyraizyn, config, kor, krioniksRev, nixOSRev, uyrld, ... }:
let
  inherit (builtins) mapAttrs;
  inherit (lib) mkOverride;
  inherit (uyrld) mkHomeConfig;

  profile = "light";

  mkUserConfig = name: krimyn:
    let kriozon = hyraizyn; in
    mkHomeConfig { inherit krimyn profile kriozon; };

in
{
  boot = {
    supportedFilesystems = mkOverride 10 [ "btrfs" "vfat" "xfs" "ntfs" ];
  };

  home-manager = {
    backupFileExtension = "backup";
    users = mapAttrs mkUserConfig hyraizyn.krimynz;
  };

  isoImage = {
    isoBaseName = "krioniks";
    volumeID = "krioniks-${krioniksRev}-${nixOSRev}-${pkgs.stdenv.hostPlatform.uname.processor}";

    makeUsbBootable = true;
    makeEfiBootable = true;
  };

}
