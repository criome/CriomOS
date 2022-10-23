{ config, kor, metastrizSpiciz, Metastriz, ... }:
let
  inherit (builtins) filter concatStringsSep listToAttrs hasAttr attrNames concatMap elem;
  inherit (kor) louestOf nameValuePair filterAttrs spiciDatum optional
    mapAttrsToList optionalAttrs optionalString arkSistymMap unique;
  inherit (config) metastraNeim astraNeim;
  inherit (metastrizSpiciz) metastriNeimz;

  inputMetastra = Metastriz.${metastraNeim};
  inputAstriz = inputMetastra.astriz;
  inputAstra = inputAstriz.${astraNeim};

  astriNeimz = attrNames inputMetastra.astriz;
  krimynNeimz = attrNames inputMetastra.krimynz;

  neksysKrioniksNeim = concatStringsSep "."
    [ metastraNeim "kriom" ];

  metaTrost = inputMetastra.trost.metastra;

  mkTrost = yrei: louestOf (yrei ++ [ metaTrost ]);

  mkEseseitcString = priKriom:
    if (priKriom == null) then "" else
    concatStringsSep " " [ "ssh-ed25519" priKriom ];

  mkAstri = astriNeim:
    let
      inputAstri = inputAstriz.${astriNeim};
      inherit (inputAstri.priKriomz) yggdrasil;

      filteredMycin = spiciDatum {
        datum = inputAstri.mycin;
        spek = {
          metyl = [ "ark" "mothyrBord" "modyl" ];
          pod = [ "ark" "ubyrAstri" "ubyrKrimyn" ];
        };
      };

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

        krioniksNeim = concatStringsSep "."
          [ astriNeim neksysKrioniksNeim ];

        sistym = arkSistymMap.${mycin.ark};

        nbOfBildKorz = 1; #TODO
      };

      spinyrz =
        let
          inherit (astri) spici trost saiz niksPriKriom
            yggAddress krioniksNeim;

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
          izNiksKriodaizd = niksPriKriom != null && niksPriKriom != "";
          izYggKriodaizd = yggAddress != null && yggAddress != "";
          izNeksisKriodaizd = izYggKriodaizd;
          izEseseitcKriodaizd = hasAttr "eseseitc" inputAstri.priKriomz;
          hazWireguardPriKriom = wireguardPriKriom != null;

          izKriodaizd = izNiksKriodaizd && izYggKriodaizd && izEseseitcKriodaizd;

          eseseitcPriKriom =
            if !izEseseitcKriodaizd then ""
            else mkEseseitcString inputAstri.priKriomz.eseseitc;

          nixPriKriom = optionalString izNiksKriodaizd
            (concatStringsSep ":" [ krioniksNeim niksPriKriom ]);

          nixCacheDomain = if izNiksKac then ("nix." + krioniksNeim) else null;
          nixUrl = if izNiksKac then ("http://" + nixCacheDomain) else null;
        };

    in
    astri // { inherit spinyrz; };

  exAstriNeimz = attrNames exAstriz;
  bildyrz = filter (n: astriz.${n}.spinyrz.izBildyr) exAstriNeimz;
  kacyz = filter (n: astriz.${n}.spinyrz.izNiksKac) exAstriNeimz;
  dispatcyrz = filter (n: astriz.${n}.spinyrz.izDispatcyr) exAstriNeimz;

  adminKrimynNeimz = filter (n: krimynz.${n}.trost == 3) krimynNeimz;

  astraSpinyrz =
    let
      mkBildyr = n:
        let astri = exAstriz.${n};
        in {
          hostName = astri.krioniksNeim;
          sshUser = "nixBuilder";
          sshKey = "/etc/ssh/ssh_host_ed25519_key";
          supportedFeatures = optional astri.spinyrz.izSentyr "big-parallel";
          system = astri.sistym;
          maxJobs = astri.nbOfBildKorz;
        };

      mkAdminKrimynPriKriomz = adminKrimynNeim:
        let
          adminKrimyn = krimynz.${adminKrimynNeim};
          priKriomAstriNeimz = attrNames adminKrimyn.priKriomz;
          izAstriFulyTrostyd = n: astriz.${n}.spinyrz.izFullyTrusted;
          fulyTrostydPriKriomNeimz = filter izAstriFulyTrostyd priKriomAstriNeimz;
          getEseseitcString = n:
            if (adminKrimyn.priKriomz.${n}.eseseitc == null)
            then "" else (mkEseseitcString adminKrimyn.priKriomz.${n}.eseseitc);
        in
        map getEseseitcString fulyTrostydPriKriomNeimz;

      inherit (astra.mycin) modyl;
      thinkpadModylz = [ "ThinkPadX240" "ThinkPadX230" ];
      impozdHTModylz = [ "ThinkPadX240" ];

      computerModylz = thinkpadModylz ++ [ "rpi3B" ];

      computerIsNotMap = builtins.listToAttrs
        (map (n: nameValuePair n false) computerModylz);

    in
    {
      bildyrKonfigz =
        let
        in
        map mkBildyr bildyrz;

      kacURLz =
        let
          mkKacURL = n: exAstriz.${n}.spinyrz.nixUrl;
        in
        map mkKacURL kacyz;

      exAstrizEseseitcPriKriomz = map
        (n:
          exAstriz.${n}.eseseitc
        )
        exAstriNeimz;

      dispatcyrzEseseitcKiz = map
        (n:
          exAstriz.${n}.eseseitc
        )
        dispatcyrz;

      adminEseseitcPriKriomz = unique
        (concatMap mkAdminKrimynPriKriomz adminKrimynNeimz);

      tcipIzIntel = elem astra.mycin.ark [ "x86-64" "i686" ]; # TODO

      modylIzThinkpad = elem astra.mycin.modyl thinkpadModylz;

      impozyzHaipyrThreding = elem astra.mycin.modyl impozdHTModylz;

      iuzColemak = astra.io.kibord == "colemak";

      computerIs = computerIsNotMap //
        (optionalAttrs (modyl != null)
          { "${modyl}" = true; });

      wireguardUntrustedProxies = astra.wireguardUntrustedProxies or [ ];
    };

  mkKrimyn = krimynNeim:
    let
      inputKrimyn = inputMetastra.krimynz.${krimynNeim};

      tcekPriKriom = astriNeim: priKriom:
        hasAttr astriNeim astriz;

      krimyn = {
        neim = krimynNeim;

        inherit (inputKrimyn) stail spici kibord;

        saiz = louestOf [ inputKrimyn.saiz astra.saiz ];

        trost = inputMetastra.trost.krimynz.${krimynNeim};

        priKriomz = filterAttrs tcekPriKriom inputKrimyn.priKriomz;

        githubId =
          if (inputKrimyn.githubId == null)
          then krimynNeim else inputKrimyn.githubId;

      };

      hazPriKriom = hasAttr astra.neim krimyn.priKriomz;

      spinyrz = {
        inherit hazPriKriom;

        saizAtList = kor.mkSaizAtList krimyn.saiz;

        matrixID = "@${krimyn.neim}:${metastra.neim}.kriom";

        gitSigningKey =
          if hazPriKriom then
            ("&" + krimyn.priKriomz.${astra.neim}.keygrip)
          else null;

        iuzColemak = krimyn.kibord == "colemak";

        izSemaDev = elem krimyn.spici [ "Sema" "Onlimityd" ];
        izNiksDev = elem krimyn.spici [ "Niks" "Onlimityd" ];

        eseseitcyz = mapAttrsToList (n: pk: mkEseseitcString pk.eseseitc)
          krimyn.priKriomz;

      } // (kor.optionalAttrs hazPriKriom {
        eseseitc = mkEseseitcString krimyn.priKriomz.${astra.neim}.eseseitc;
      });

    in
    krimyn // { inherit spinyrz; };

  astriz = listToAttrs (map
    (y: nameValuePair y.neim y)
    (filter (x: x.trost != 0)
      (map (n: mkAstri n) astriNeimz)));

  metastra = {
    neim = metastraNeim;

    spinyrz = {
      trostydBildPriKriomz = map (n: exAstriz.${n}.spinyrz.nixPriKriom) bildyrz
        ++ (optional astra.spinyrz.izNiksKriodaizd astra.spinyrz.nixPriKriom);
    };
  };

  exAstriz = kor.filterAttrs (n: v: n != astraNeim) astriz;

  astra =
    let
      astri = astriz.${astraNeim};
    in
    astri // {
      inherit (inputAstra) io;
      spinyrz = astri.spinyrz // astraSpinyrz;
    };

  krimynz = listToAttrs (map
    (y: nameValuePair y.neim y)
    (filter (x: x.trost != 0)
      (map (n: mkKrimyn n) krimynNeimz)));

in
{
  hyraizyn = {
    inherit metastra astra exAstriz krimynz;
  };
}
