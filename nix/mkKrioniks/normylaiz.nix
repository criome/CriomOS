{ config, kor, hyraizyn, pkgs, lib, uyrld, ... }:
let
  inherit (kor) mapAttrsToList eksportJSON;
  inherit (lib) concatStringsSep mkOverride optional mkIf optionalString optionalAttrs;
  inherit (pkgs) mksh writeScript gnupg;
  inherit (hyraizyn) astra exAstriz;
  inherit (hyraizyn.astra.spinyrz) tcipIzIntel saizAtList iuzColemak;

  # TODO
  hasAudioOutput = true;
  hasVideoOutput = true;
  hasAcceleratedVideoOutput = true;

  jsonHyraizynFail = eksportJSON "hyraizyn.json" hyraizyn;

  niksOSShell = mksh + mksh.shellPath;

  mkAstriKnownHost = n: astri:
    concatStringsSep " " [ astri.krioniksNeim astri.eseseitc ];

  sshKnownHosts = concatStringsSep "\n"
    (mapAttrsToList mkAstriKnownHost exAstriz);

in
{
  boot = {
    kernelParams = [ "consoleblank=300" ];

    kernelPackages = pkgs.linuxPackages_latest;

    supportedFilesystems = mkOverride 50
      ([ "xfs" "btrfs" ] ++ (optional saizAtList.min "exfat"));
  };

  documentation = {
    enable = !config.boot.isContainer;
    nixos.enable = !config.boot.isContainer;
  };

  environment = {
    binsh = niksOSShell;
    shells = [ "/run/current-system/sw${mksh.shellPath}" ];

    etc = {
      "systemd/user-environment-generators/ssh-sock.sh".source =
        writeScript "user-ssh-sock.sh" ''
          #!${pkgs.mksh}/bin/mksh
            echo "SSH_AUTH_SOCK=$(${gnupg}/bin/gpgconf --list-dirs agent-ssh-socket)"
        '';
      "ssh/ssh_known_hosts".text = sshKnownHosts;
      "hyraizyn.json" = {
        source = jsonHyraizynFail;
        mode = "0600";
      };
    };

    systemPackages = with pkgs; [
      uyrld.skrips.root
      tcpdump
    ];

    interactiveShellInit = optionalString iuzColemak "stty -ixon";
    sessionVariables = (optionalAttrs iuzColemak {
      XKB_DEFAULT_LAYOUT = "us";
      XKB_DEFAULT_VARIANT = "colemak";
    });
  };

  networking.networkmanager.enable = saizAtList.min;

  nixpkgs.config.allowUnfree = true;

  programs = {

    adb.enable = saizAtList.med;

    light.enable = hasVideoOutput;

    sway = mkIf hasAcceleratedVideoOutput {
      enable = true;
      wrapperFeatures = {
        base = true;
        gtk = true;
      };

      extraSessionCommands = ''
        export QT_QPA_PLATFORM=wayland
        export QT_WAYLAND_DISABLE_WINDOWDECORATION="1"
        export GDK_BACKEND=wayland
      '';
    };

    zsh.enable = true;
  };

  services = {
    openssh = {
      enable = true;
      passwordAuthentication = false;
      ports = [ 22 ];
    };

    pipewire = mkIf hasAudioOutput {
      enable = true;
      alsa.enable = true;
      jack.enable = true;
      pulse.enable = true;
    };

    udev = {
      extraRules = ''
        # What is this for?
        ATTRS{idVendor}=="067b", ATTRS{idProduct}=="2303", GROUP="dialout", MODE="0660"
      '';
    };
  };

  sound = {
    enable = true;
    extraConfig = "";
  };

  systemd = {
    package = pkgs.systemd.override {
      withHomed = true;
    };
  };

  users = {
    defaultUserShell = "/run/current-system/sw/bin/zsh";
    groups.dialout = { };
  };

}
