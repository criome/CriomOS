{ lib, config, kor, metastrizSpiciz, Metastriz, ... }:
let
  inherit (builtins) filter concatStringsSep listToAttrs hasAttr attrNames concatMap elem;
  inherit (kor) louestOf nameValuePair filterAttrs spiciDatum optional
    mapAttrsToList optionalAttrs optionalString arkSistymMap unique;
  inherit (config) metastraNeim astraNeim spiciz;
  inherit (metastrizSpiciz) metastriNeimz astriSpiciz;

  inputMetastra = Metastriz.${metastraNeim};
  inputAstriz = inputMetastra.astriz;
  inputAstra = inputAstriz.${astraNeim};

  astriNeimz = attrNames inputMetastra.astriz;
  userNeimz = attrNames inputMetastra.users;

  neksysCriomOSNeim = concatStringsSep "."
    [ metastraNeim "criome" ];

  metaTrost = inputMetastra.trost.metastra;

  mkTrost = yrei: louestOf (yrei ++ [ metaTrost ]);

  mkEseseitcString = priCriome:
    if (priCriome == null) then "" else
    concatStringsSep " " [ "ssh-ed25519" priCriome ];

  mkAstri = astriNeim:
    let
      # (TODO typecheck)
      inputAstri = inputAstriz.${astriNeim};
      inherit (inputAstri) saiz spici;
      inherit (inputAstri.priCriomez) yggdrasil;

      filteredMycin = spiciDatum {
        datum = inputAstri.mycin;
        spek = {
          metyl = [ "ark" "mothyrBord" "modyl" ];
          pod = [ "ark" "ubyrAstri" "ubyrUser" ];
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
      wireguardPriCriome = inputAstri.wireguardPriCriome or null;

      mkTypeIsFromTypeName = name:
        let isOfThisType = name == spici; in
        nameValuePair name isOfThisType;

      astri = {
        inherit saiz spici;

        neim = astriNeim;
        inherit mycin wireguardPriCriome neksysIp;

        linkLocalIPs =
          if (hasAttr "linkLocalIPs" inputAstri)
          then (map mkLinkLocalIP inputAstri.linkLocalIPs)
          else [ ];

        trost = mkTrost
          [ inputAstri.trost inputMetastra.trost.astriz.${astriNeim} ];

        eseseitc = mkEseseitcString inputAstri.priCriomez.eseseitc;

        yggPriCriome = yggdrasil.priCriome;
        yggAddress = yggdrasil.address;
        yggSubnet = yggdrasil.subnet;

        inherit (inputAstri.priCriomez) niksPriCriome;

        criomeOSNeim = concatStringsSep "."
          [ astriNeim neksysCriomOSNeim ];

        sistym = arkSistymMap.${mycin.ark};

        nbOfBildKorz = 1; #TODO

        typeIs = listToAttrs
          (map mkTypeIsFromTypeName astriSpiciz);
      };

      spinyrz =
        let
          inherit (astri) spici trost saiz niksPriCriome
            yggAddress criomeOSNeim typeIs;

        in
        rec {
          izFullyTrusted = trost == 3;
          saizAtList = kor.mkSaizAtList saiz;
          izBildyr = !typeIs.edj && izFullyTrusted && (saizAtList.med || typeIs.sentyr) && izCriodaizd;
          izDispatcyr = !typeIs.sentyr && izFullyTrusted && saizAtList.min;
          izNiksKac = typeIs.sentyr && saizAtList.min && izCriodaizd;
          izNiksCriodaizd = niksPriCriome != null && niksPriCriome != "";
          izYggCriodaizd = yggAddress != null && yggAddress != "";
          izNeksisCriodaizd = izYggCriodaizd;
          izEseseitcCriodaizd = hasAttr "eseseitc" inputAstri.priCriomez;
          hazWireguardPriCriome = wireguardPriCriome != null;

          izCriodaizd = izNiksCriodaizd && izYggCriodaizd && izEseseitcCriodaizd;

          eseseitcPriCriome =
            if !izEseseitcCriodaizd then ""
            else mkEseseitcString inputAstri.priCriomez.eseseitc;

          nixPriCriome = optionalString izNiksCriodaizd
            (concatStringsSep ":" [ criomeOSNeim niksPriCriome ]);

          nixCacheDomain = if izNiksKac then ("nix." + criomeOSNeim) else null;
          nixUrl = if izNiksKac then ("http://" + nixCacheDomain) else null;


        };

    in
    astri // { inherit spinyrz; };

  exAstriNeimz = attrNames exAstriz;
  bildyrz = filter (n: astriz.${n}.spinyrz.izBildyr) exAstriNeimz;
  kacyz = filter (n: astriz.${n}.spinyrz.izNiksKac) exAstriNeimz;
  dispatcyrz = filter (n: astriz.${n}.spinyrz.izDispatcyr) exAstriNeimz;

  adminUserNeimz = filter (n: users.${n}.trost == 3) userNeimz;

  astraSpinyrz =
    let
      mkBildyr = n:
        let astri = exAstriz.${n};
        in {
          hostName = astri.criomeOSNeim;
          sshUser = "nixBuilder";
          sshKey = "/etc/ssh/ssh_host_ed25519_key";
          supportedFeatures = optional (!astri.typeIs.edj) "big-parallel";
          system = astri.sistym;
          systems = lib.optional (astri.sistym == "x86_64-linux") "i686-linux";
          maxJobs = astri.nbOfBildKorz;
        };

      mkAdminUserPriCriomez = adminUserNeim:
        let
          adminUser = users.${adminUserNeim};
          priCriomeAstriNeimz = attrNames adminUser.priCriomez;
          izAstriFulyTrostyd = n: astriz.${n}.spinyrz.izFullyTrusted;
          fulyTrostydPriCriomeNeimz = filter izAstriFulyTrostyd priCriomeAstriNeimz;
          getEseseitcString = n:
            if (adminUser.priCriomez.${n}.eseseitc == null)
            then "" else (mkEseseitcString adminUser.priCriomez.${n}.eseseitc);
        in
        map getEseseitcString fulyTrostydPriCriomeNeimz;

      inherit (astra.mycin) modyl;
      thinkpadModylz = [ "ThinkPadX240" "ThinkPadX230" ];
      impozdHTModylz = [ "ThinkPadX240" ];

      computerModylz = thinkpadModylz ++ [ "rpi3B" ];

      computerIsNotMap = listToAttrs
        (map (n: nameValuePair n false) computerModylz);

    in
    {
      bildyrKonfigz = map mkBildyr bildyrz;

      kacURLz =
        let
          mkKacURL = n: exAstriz.${n}.spinyrz.nixUrl;
        in
        map mkKacURL kacyz;

      exAstrizEseseitcPriCriomez = map
        (n:
          exAstriz.${n}.eseseitc
        )
        exAstriNeimz;

      dispatcyrzEseseitcKiz = map
        (n:
          exAstriz.${n}.eseseitc
        )
        dispatcyrz;

      adminEseseitcPriCriomez = unique
        (concatMap mkAdminUserPriCriomez adminUserNeimz);

      tcipIzIntel = elem astra.mycin.ark [ "x86-64" "i686" ]; # TODO

      modylIzThinkpad = elem astra.mycin.modyl thinkpadModylz;

      impozyzHaipyrThreding = elem astra.mycin.modyl impozdHTModylz;

      iuzColemak = astra.io.kibord == "colemak";

      computerIs = computerIsNotMap //
        (optionalAttrs (modyl != null)
          { "${modyl}" = true; });

      wireguardUntrustedProxies = astra.wireguardUntrustedProxies or [ ];
    };

  mkUser = userNeim:
    let
      inputUser = inputMetastra.users.${userNeim};

      tcekPriCriome = astriNeim: priCriome:
        hasAttr astriNeim astriz;

      user = {
        neim = userNeim;

        inherit (inputUser) stail spici kibord;

        saiz = louestOf [ inputUser.saiz astra.saiz ];

        trost = inputMetastra.trost.users.${userNeim};

        priCriomez = filterAttrs tcekPriCriome inputUser.priCriomez;

        githubId =
          if (inputUser.githubId == null)
          then userNeim else inputUser.githubId;

      };

      hazPriCriome = hasAttr astra.neim user.priCriomez;

      spinyrz = {
        inherit hazPriCriome;

        saizAtList = kor.mkSaizAtList user.saiz;

        emailAddress = "${user.neim}@${metastra.neim}.criome.me";
        matrixID = "@${user.neim}:${metastra.neim}.criome.me";

        gitSigningKey =
          if hazPriCriome then
            ("&" + user.priCriomez.${astra.neim}.keygrip)
          else null;

        iuzColemak = user.kibord == "colemak";

        izSemaDev = elem user.spici [ "Sema" "Onlimityd" ];
        izNiksDev = elem user.spici [ "Niks" "Onlimityd" ];

        eseseitcyz = mapAttrsToList (n: pk: mkEseseitcString pk.eseseitc)
          user.priCriomez;

      } // (kor.optionalAttrs hazPriCriome {
        eseseitc = mkEseseitcString user.priCriomez.${astra.neim}.eseseitc;
      });

    in
    user // { inherit spinyrz; };

  astriz = listToAttrs (map
    (y: nameValuePair y.neim y)
    (filter (x: x.trost != 0)
      (map (n: mkAstri n) astriNeimz)));

  metastra = {
    neim = metastraNeim;

    spinyrz = {
      trostydBildPriCriomez = map (n: exAstriz.${n}.spinyrz.nixPriCriome) bildyrz
        ++ (optional astra.spinyrz.izNiksCriodaizd astra.spinyrz.nixPriCriome);
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

  users = listToAttrs (map
    (y: nameValuePair y.neim y)
    (filter (x: x.trost != 0)
      (map (n: mkUser n) userNeimz)));

in
{
  hyraizyn = {
    inherit metastra astra exAstriz users;
  };
}