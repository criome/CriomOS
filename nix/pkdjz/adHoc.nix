hob:
let
  inherit (builtins) mapAttrs;

in
{
  jumpdrive = {
    modz = [ "pkgs" "pkdjz" ];
    src = null;
    lamdy = { stdenv, fetchurl, mksh, writeScript, mfgtools }:
      let
        mkRelease = name: versionAndNarHashes:
          let
            inherit (versionAndNarHashes) version narHash;

            url =
              "https://github.com/dreemurrs-embedded/Jumpdrive/releases/download/${version}/${name}.tar.xz";

            src = fetchurl {
              inherit url; hash = narHash;
            };

            launcherName = ("jumpdrive-" + name);
            dataDirectory = "share/jumpdrive/${name}";

            launcherScript = writeScript launcherName ''
              #!${mksh}/bin/mksh
              cd $(dirname $0)/../${dataDirectory}
              ${mfgtools}/bin/uuu ${name}.lst
            '';

          in
          stdenv.mkDerivation {
            inherit name src;
            phases = [ "unpackPhase" "installPhase" ];

            unpackPhase = "tar xf $src";

            installPhase = ''
              mkdir -p $out/bin
              cp ${launcherScript} $out/bin/${launcherName}
              mkdir -p $out/${dataDirectory}
              cp -R ./* $out/${dataDirectory}
            '';
          };

        releasesNarHashes = {
          purism-librem5 = {
            version = "0.8";
            narHash = "sha256-tEtl16tyu/GbAWceDXZTP4R+ajmAksIzwmwlWYZkTYc=";
          };
        };

        releases = mapAttrs mkRelease releasesNarHashes;

      in
      releases;
  };
}
