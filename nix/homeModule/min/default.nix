{ kor, pkgs, pkdjz, krimyn, hyraizyn, config, profile, uyrld, ... }:
let
  inherit (builtins) concatStringsSep toString readFile toJSON;
  inherit (kor) optionalString optionals mkIf mapAttrsToList optional;
  inherit (pkdjz) kynvyrt;
  inherit (hyraizyn) astra;
  inherit (krimyn.spinyrz) iuzColemak hazPriKriom
    gitSigningKey matrixID saizAtList izNiksDev;
  inherit (krimyn) githubId neim;
  inherit (profile) dark;

  homeDir = config.home.homeDirectory;

  zshEksek = "${pkgs.zsh}/bin/zsh";

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
    pijul
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

  ] ++ (optionals izNiksDev [
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
  ]));

  uyrldPackages = with uyrld; [
    pkdjz.shen-bootstrap
    skrips.user
  ];

in
mkIf saizAtList.min {
  services = {
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
