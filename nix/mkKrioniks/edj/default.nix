{ kor, hyraizyn, config, pkgs, lib, uyrld, ... }:
let
  inherit (kor) mkIf optional optionals optionalString optionalAttrs;
  inherit (lib) mkOverride;

  inherit (hyraizyn.astra.spinyrz) saizAtList izEdj;

  medPackages = optionals saizAtList.med (with pkgs; [ ]);
  maxPackages = optionals saizAtList.max (with pkgs; [ ]);

in
{
  hardware.pulseaudio.enable = false;

  environment = {
    systemPackages = [ ] ++ medPackages ++ maxPackages;

    gnome.excludePackages = with pkgs.gnome3; [
      gnome-software
    ];
  };

  programs = {
    file-roller.enable = saizAtList.med;
    fish.enable = saizAtList.min;
    geary.enable = mkIf saizAtList.med (mkOverride 0 false); # force to disable keyring
  };

  services = {
    power-profiles-daemon.enable = false;

    dbus.packages = mkIf saizAtList.med [ pkgs.gcr ];

    gnome = {
      gnome-initial-setup.enable = false;
      gnome-browser-connector.enable = false;
      gnome-keyring.enable = lib.mkForce false; # To avoid overriding SSH_AUTH_SOCK
    };

    tumbler.enable = saizAtList.med;

    xserver = {
      enable = saizAtList.med;
      excludePackages = with pkgs; [ xorg.xorgserver.out ];
      displayManager = {
        gdm = {
          enable = saizAtList.med;
          autoSuspend = izEdj;
        };
      };

      desktopManager = {
        gnome = {
          enable = saizAtList.max;
          extraGSettingsOverrides = ''
            [org.gnome.desktop.peripherals.touchpad]
            tap-to-click=true
          '';
        };
      };
    };
  };
}
