{ kor, hyraizyn, config, pkgs, lib, uyrld, ... }:
let
  inherit (kor) mkIf optional optionals optionalString optionalAttrs;
  inherit (lib) mkOverride;

  inherit (hyraizyn.astra.spinyrz) saizAtList izEdj;

  minPackages = optionals saizAtList.min (with pkgs.gnome; [
    adwaita-icon-theme
    nautilus
  ]);

  medPackages = optionals saizAtList.med (with pkgs; [ ]);
  maxPackages = optionals saizAtList.max (with pkgs; [ ]);

in
{
  hardware.pulseaudio.enable = false;

  environment = {
    systemPackages = with pkgs; minPackages ++ medPackages ++ maxPackages;

    gnome.excludePackages = with pkgs.gnome3; [
      gnome-software
    ];
  };

  programs = {
    droidcam.enable = saizAtList.max;
    file-roller.enable = saizAtList.med;
    fish.enable = saizAtList.min;
    zsh.enable = true;

    hyprland = {
      enable = true;
    };

    regreet = {
      enable = !(saizAtList.min);
      settings = {
        GTK = {
          application_prefer_dark_theme = true;
          cursor_theme_name = "Adwaita";
          icon_theme_name = "Adwaita";
          theme_name = "Adwaita";
        };
      };
    };

    sway = {
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
  };

  services = {
    power-profiles-daemon.enable = false;

    dbus.packages = mkIf saizAtList.med [ pkgs.gcr ];

    gnome = {
      core-utilities.enable = true;
    };

    tumbler.enable = saizAtList.med;

    xserver = {
      enable = saizAtList.min;
      excludePackages = with pkgs; [ xorg.xorgserver.out ];
      displayManager = {
        gdm = {
          enable = saizAtList.min;
          autoSuspend = izEdj;
        };
      };
    };
  };

  xdg = {
    portal = {
      enable = true;
      wlr.enable = true;
    };
  };
}
