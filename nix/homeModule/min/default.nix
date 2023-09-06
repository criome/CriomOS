{ kor, pkgs, pkdjz, krimyn, hyraizyn, config, profile, uyrld, ... }:
let
  inherit (builtins) concatStringsSep toString readFile toJSON;
  inherit (kor) optionalString optionals mkIf mapAttrsToList optional;
  inherit (pkdjz) kynvyrt;
  inherit (hyraizyn) astra;
  inherit (krimyn.spinyrz) iuzColemak hazPriKriom
    gitSigningKey matrixID saizAtList izNiksDev izSemaDev;
  inherit (krimyn) githubId neim;
  inherit (profile) dark;
  inherit (pkgs) writeText;

  homeDir = config.home.homeDirectory;

  fzfBinds = [ ];
  fzfColemakBinds = import ./fzfColemak.nix;

  mkFzfBinds = list: "--bind=" + (concatStringsSep "," list);

  fzfBindsString = mkFzfBinds (fzfBinds ++ (optionals iuzColemak fzfColemakBinds));

  fzfColors = if dark then import ./fzfDark.nix else import ./fzfLight.nix;
  fzfBase16Map = import ./fzfBase16map.nix;

  mkFzfColor = n: v:
    let color = fzfColors.${v};
    in "${n}:${color}";

  fzfColorString = "--color=" + (concatStringsSep ","
    (mapAttrsToList mkFzfColor fzfBase16Map));

  fzfOptsString = toString [ fzfBindsString fzfColorString ];

  ovyridynFzf = pkgs.fzf.overrideAttrs (oldAttrs: {
    nativeBuildInputs = oldAttrs.nativeBuildInputs
      ++ [ pkgs.makeWrapper ];
    postInstall = oldAttrs.postInstall +
      ''
         wrapProgram $out/bin/fzf \
        --set-default FZF_DEFAULT_OPTS "${fzfOptsString}" \
        --set-default FZF_DEFAULT_COMMAND "${pkgs.fd}/bin/fd --type file" \
      '';
  });

  waylandQtpass = pkgs.qtpass.override { pass = waylandPass; };
  waylandPass = pkgs.pass.override { x11Support = false; waylandSupport = true; };

  fontDeriveicynz = [ pkgs.noto-fonts-cjk ]
    ++ (optionals saizAtList.med (with pkgs; [
    pkdjz.nerd-fonts.firaCode
    fira-code
  ]));

  mkFcCache = pkgs.makeFontsCache { fontDirectories = fontDeriveicynz; };

  mkFontPaths = kor.concatMapStringsSep "\n"
    (path: "<dir>${path}/share/fonts</dir>")
    fontDeriveicynz;

  mkFontConf = ''
    <?xml version='1.0'?>
    <!DOCTYPE fontconfig SYSTEM 'fonts.dtd'>
    <fontconfig>
      ${mkFontPaths}
      <cachedir>${mkFcCache}</cachedir>
    </fontconfig>
  '';

  mkFootSrcTheme = themeName:
    let
      themeString = readFile (pkgs.foot.src + "/themes/${themeName}");
    in
    writeText "foot-theme-${themeName}" themeString;

  footThemeFile =
    let
      darkTheme = mkFootSrcTheme "derp";
      lightTheme = mkFootSrcTheme "selenized-white";
    in
    if dark then darkTheme else lightTheme;

  bleedingEdgeGraphicalPackages = with pkdjz.pkgs-master; [ ];

  modernGraphicalPackages = with pkgs; [
    ledger-live-desktop
    element-desktop
    # C
    # ctags
    swaylock
    grim
    slurp
    waybar
    zathura
    wl-clipboard
    libnotify
    imv
    wf-recorder
    libva-utils
    ffmpeg-full
    # start("GTK")
    wofi
    gitg
    pavucontrol
    sonata
    dino
    transmission-remote-gtk
    ptask
    bookworm
    # start("Qt")
    adwaita-qt
    qgnomeplatform
    waylandQtpass
    qtox
    waylandPass
    qpwgraph
    # TODO('hyraizyn language')
    (hunspellWithDicts [ hunspellDicts.en-us-large ])
    (aspellWithDicts (ds: with ds; [ en en-computers en-science ]))
    hunspellDicts.en-us-large
    tor-browser-bundle-bin
  ];

  brootConfig = toJSON { };

  mpv = pkgs.wrapMpv
    (pkgs.mpv-unwrapped.override {
      x11Support = false;
      xineramaSupport = false;
      xvSupport = false;
      waylandSupport = true;
      screenSaverSupport = false;
    })
    { youtubeSupport = saizAtList.med; };

  nixpkgsPackages = with pkgs; [
    mksh # saner bash
    retry
    ovyridynFzf
    alsaUtils
    pamixer
    ncpamixer
    mpv
    flac
    shntool
    dvtm
    abduco # Multiplexer/session
    vis # regex Editor
    tree
    ncdu # File visualizing
    unzip
    unrar
    fuse
    cryptsetup
    # Network
    sshfs-fuse
    ifmetric
    curl
    wget
    transmission
    aria2 # multi-protocol download
    rsync
    nload
    nmap
    iftop
    # Wireless
    iw
    wirelesstools
    acpi
    sox # audio capture
    tio # serial tty
    androidenv.androidPkgs_9_0.platform-tools # adb/fastboot
    #== rust
    sd
    ripgrep
    fd
    exa
    bat
    broot
    tokei # loc counter
    eva # tui calculator

  ]
  ++ bleedingEdgeGraphicalPackages # (Todo configure)
  ++ modernGraphicalPackages # (Todo configure)
  ++ (optionals izNiksDev [
    # Clojure
    clojure
    babashka
    clj-kondo
    # lisp
    zprint

    lsof
    miniserve
    yggdrasil
    delta
    cpulimit
    usbutils
    pciutils
    efivar # Hardware
    lshw
    gptfdisk
    parted # Disk utils
    avrdude
    wireguard-tools
    pkdjz.firn
    pkdjz.crate2nix
    cargo
    shfmt
  ] ++ (optionals (astra.mycin.ark == "x86-64") [
    i7z
  ]))
  ++ (optionals izSemaDev (with pkgs; [
    inkscape
  ]));

  uyrldPackages = with uyrld; [
    pkdjz.shen-bootstrap
    skrips.user
  ];

in
mkIf saizAtList.min {
  services = {
    dunst = {
      enable = true;
      # (TODO theme)
      settings = {
        global = {
          geometry = "300x5-30+50";
          transparency = 10;
          frame_color = "#eceff1";
          font = "Fira Code 10";
        };

        urgency_normal = {
          background = "#37474f";
          foreground = "#eceff1";
          timeout = 10;
        };
      };
    };

    pantalaimon = {
      enable = true;
      settings = {
        Default = {
          LogLevel = "Debug";
          SSL = true;
        };
        local-matrix = {
          Homeserver = "https://matrix.org";
          ListenAddress = "127.0.0.1";
          ListenPort = 8009;
          IgnoreVerification = true;
          SSL = false;
        };
      };
    };

    gammastep = {
      enable = true;
      provider = "geoclue2";
      temperature = {
        day = 6000;
        night = 2700;
      };
    };

    gpg-agent = {
      enable = true;
      verbose = true;
      pinentryFlavor = "gnome3";
      defaultCacheTtl = 10800;
      maxCacheTtl = 86400;
      defaultCacheTtlSsh = 3600;
      maxCacheTtlSsh = 86400;
      enableSshSupport = true;
      sshKeys = (optional hazPriKriom krimyn.priKriomz.${astra.neim}.keygrip);
    };

    mpd = {
      enable = true;
      musicDirectory = "~/Music";
    };

    pueue = { enable = izNiksDev; };
  };

  programs = {
    bat = {
      enable = true;
      config = {
        theme = "gruvbox-${if dark then "dark" else "light"}";
        pager = "less -FR";
      };
    };

    direnv = {
      enable = izNiksDev;
      nix-direnv.enable = izNiksDev;
    };

    foot = {
      enable = true;
      settings = {
        main = {
          include = toString footThemeFile;
          font = "Fira Code:size=9";
        };
      };
    };

    git = {
      enable = true;
      userEmail = matrixID;
      userName = neim;
      signing = mkIf hazPriKriom {
        key = gitSigningKey;
        signByDefault = true;
      };
      extraConfig = {
        pull.rebase = true;
        init.defaultBranch = "main";
        github.user = githubId;
        ghq.root = "/git";
        hub.protocol = "ssh";
      };
    };

    gpg = {
      enable = true;
      settings = { };
    };

    htop = {
      enable = true;
      settings = {
        highlight_base_name = 1;
      };
    };

    starship = {
      enable = true;
    };

    zsh = {
      enable = true;
      dotDir = ".config/zsh";
      history = {
        ignoreDups = true;
        expireDuplicatesFirst = true;
      };

      defaultKeymap = "viins";

      sessionVariables = {
        FZF_DEFAULT_OPTS = "${fzfOptsString}";
        FZF_DEFAULT_COMMAND = "${pkgs.fd}/bin/fd --type file";
        RSYNC_OLD_ARGS = 1;
      };

      shellAliases = {
        tsync = "rsync --progress --recursive";
        nsync = "rsync --checksum --progress --recursive";
        dsync = "rsync --checksum --progress --recursive --delete";
      };

      initExtra = builtins.readFile ../nonNix/zshrc +
        ''
          if [[ $options[zle] = on ]]; then
          . ${ovyridynFzf}/share/fzf/completion.zsh
          . ${ovyridynFzf}/share/fzf/key-bindings.zsh
          . ${pkgs.zsh-fzf-tab}/share/fzf-tab/fzf-tab.zsh
          fi
        ''
        + (optionalString iuzColemak (builtins.readFile ../nonNix/colemak.zsh));
    };

    zoxide.enable = true;
  };

  home = {
    packages = nixpkgsPackages ++ uyrldPackages;

    pointerCursor = {
      package = pkgs.vanilla-dmz;
      name = "Vanilla-DMZ";
    };

    file = {
      ".config/gtk-3.0/settings.ini".text = ''
        [Settings]
        gtk-application-prefer-dark-theme=${if dark then "1" else "0"}
      '';

      ".config/IJHack/QtPass.conf".text = ''
        [General]
        autoclearSeconds=20
        passwordLength=32
        useTrayIcon=false
        hideContent=false
        hidePassword=true
        clipBoardType=1
        hideOnClose=false
        passExecutable=${waylandPass}/bin/pass
        passTemplate=login\nurl
        pwgenExecutable=${pkgs.pwgen}bin/pwgen
        startMinimized=false
        templateAllFields=false
        useAutoclear=true
        useTrayIcon=false
        version=${pkgs.qtpass.version}
      '';

      ".config/broot/conf.toml".text = brootConfig;

      ".cargo/config.toml".source = kynvyrt {
        neim = "cargo-config";
        format = "toml";
        valiu = {
          build.target-dir = "${homeDir}/.cargo/sharedTarget";
          registries.crates-io.index = "file:///hob/github.com/rust-lang/crates.io-index/.git";
          unstable.weak-dep-features = true;
        };
      };
    };
  };

  xdg.configFile = {
    "fontconfig/conf.d/10-niksIuzyr-fonts.conf".text = mkFontConf;

    "jj/config.toml".source = kynvyrt {
      neim = "jujutsuConfigToml";
      format = "toml";
      valiu.user = {
        name = neim;
        email = matrixID;
      };
    };
  };
}
