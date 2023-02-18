{ kor, subKrioms, lib }:
let
  inherit (builtins) filter concatStringsSep listToAttrs hasAttr attrNames concatMap elem
    mapAttrs filterAttrs;
  inherit (kor) louestOf nameValuePair spiciDatum optional
    mapAttrsToList optionalAttrs optionalString arkSistymMap unique;

  mkHorizon = subKriomName: name: nexusKriozon:
    let
      astriNeim = name;
      metastraNeim = subKriomName;
      inputMetastra = subKrioms.${metastraNeim};
      inputAstri = nexusKriozon;
      astriz = horizons.${subKriomName};

      neksysKriomOSNeim = concatStringsSep "."
        [ metastraNeim "kriom" ];

      inherit (inputAstri.priKriomz) yggdrasil;

      metaTrost = inputMetastra.trost.metastra;
      filteredMycin = spiciDatum {
        datum = inputAstri.mycin;
        spek = {
          metyl = [ "ark" "mothyrBord" "modyl" ];
          pod = [ "ark" "ubyrAstri" "ubyrKrimyn" ];
        };
      };


      mkEseseitcString = priKriom:
        if (priKriom == null) then "" else
        concatStringsSep " " [ "ssh-ed25519" priKriom ];

      mkTrost = yrei: louestOf (yrei ++ [ metaTrost ]);

      rytyrnArkFromMothyrBord = mb: abort "Missing mothyrBord table";

      tcekdArk =
        if (filteredMycin.ark != null)
        then filteredMycin.ark
        else if (filteredMycin.spici == "pod")
        then astriz.${filteredMycin.ubyrAstri}.mycin.ark
        else if (filteredMycin.mothyrBord != null)
        then (rytyrnArkFromMothyrBord filteredMycin.mothyrBord)
        else abort "Missing mycin ark";

      mycin = filteredMycin // { ark = tcekdArk; };

      mkLinkLocalIP = linkLocalIP: with linkLocalIP;
        let
          interface =
            if (spici == "ethernet") then "enp0s25"
            else "wlp3s0";
        in
        "fe80::${suffix}%${interface}";

      neksysIp = inputAstri.neksysIp or null;
      wireguardPriKriom = inputAstri.wireguardPriKriom or null;

      astri = {
        neim = astriNeim;
        inherit mycin wireguardPriKriom neksysIp;
        inherit (inputAstri) saiz spici;

        linkLocalIPs =
          if (hasAttr "linkLocalIPs" inputAstri)
          then (map mkLinkLocalIP inputAstri.linkLocalIPs)
          else [ ];

        trost = mkTrost
          [ inputAstri.trost inputMetastra.trost.astriz.${astriNeim} ];

        eseseitc = mkEseseitcString inputAstri.priKriomz.eseseitc;

        yggPriKriom = yggdrasil.priKriom;
        yggAddress = yggdrasil.address;
        yggSubnet = yggdrasil.subnet;

        inherit (inputAstri.priKriomz) niksPriKriom;

        kriomOSNeim = concatStringsSep "."
          [ astriNeim neksysKriomOSNeim ];

        sistym = arkSistymMap.${mycin.ark};

        nbOfBildKorz = 1; #TODO
      };

      spinyrz =
        let
          inherit (astri) spici trost saiz niksPriKriom
            yggAddress kriomOSNeim;

        in
        rec {
          izFullyTrusted = trost == 3;
          saizAtList = kor.mkSaizAtList saiz;
          izEdj = spici == "edj";
          izSentyr = spici == "sentyr";
          izHaibrid = spici == "haibrid";
          izBildyr = !izEdj && izFullyTrusted && (saizAtList.med || izSentyr) && izKriodaizd;
          izDispatcyr = !izSentyr && izFullyTrusted && saizAtList.min;
          izNiksKac = izSentyr && saizAtList.min && izKriodaizd;
          izNiksKriodaizd = niksPriKriom != null;
          izYggKriodaizd = yggAddress != null;
          izNeksisKriodaizd = izYggKriodaizd;
          izEseseitcKriodaizd = hasAttr "eseseitc" inputAstri.priKriomz;
          hazWireguardPriKriom = wireguardPriKriom != null;

          izKriodaizd = izNiksKriodaizd && izYggKriodaizd && izEseseitcKriodaizd;

          eseseitcPriKriom =
            if !izEseseitcKriodaizd then ""
            else mkEseseitcString inputAstri.priKriomz.eseseitc;

          nixPriKriom = optionalString izNiksKriodaizd
            (concatStringsSep ":" [ kriomOSNeim niksPriKriom ]);

          nixCacheDomain = if izNiksKac then ("nix." + kriomOSNeim) else null;
          nixUrl = if izNiksKac then ("http://" + nixCacheDomain) else null;
        };

    in
    astri // { inherit spinyrz; };

  mkSubzoneHorizons = subKriomName: subKriom:
    let
      mkHorizonPrimed = mkHorizon subKriomName;
      nexi = mapAttrs mkHorizonPrimed subKriom;
      subKriom = mkSubzone subKriomName;
    in
    mapAttrs mkHorizonPrimed subKriom;

  horizons = mapAttrs mkSubzoneHorizons subKrioms;

in
horizons
