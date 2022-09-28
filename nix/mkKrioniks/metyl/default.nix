{ lib, hyraizyn, kor, config, pkgs, ... }:
let
  inherit (builtins) readFile genList concatStringsSep;
  inherit (kor) mkIf optional optionals optionalString optionalAttrs isOdd;
  inherit (lib.generators) toINI;
  inherit (hyraizyn.astra.mycin) modyl korz;
  inherit (hyraizyn.astra.spinyrz) saizAtList tcipIzIntel modylIzThinkpad
    impozyzHaipyrThreding iuzColemak izSentyr izEdj computerIs;

  # TODO
  hasTouchpad = true;

  hasThunderbolt = modyl == "ThinkPadE15Gen2Intel";
  hasNvme = modyl == "ThinkPadE15Gen2Intel";
  requiresSofFirmware = modyl == "ThinkPadE15Gen2Intel";

  izX230 = modyl == "ThinkPadX230";
  izX240 = modyl == "ThinkPadX240";

  enabledExtendedPowerSave = true;

  cpuFreqGovernor =
    if enabledExtendedPowerSave then "powersave"
    else "schedutil";

  extendedPowerSaveTable = {
    ThinkPadX240 = { min = 775000; max = 775000; };
  };

  extendedPowerSaveMinFreq = extendedPowerSaveTable."${modyl}".min;
  extendedPowerSaveMaxFreq = extendedPowerSaveTable."${modyl}".max;

  autoCpufreqSettings = {
    charger = {
      governor = cpuFreqGovernor;
      turbo = "never";
    };
    battery = {
      governor = cpuFreqGovernor;
      turbo = "never";
    };
  };

  numberOfCoresIncludingFakes = korz * 2;

  coreIsFake = coreNumber:
    if (coreNumber == 0) then false
    else if (isOdd coreNumber)
    then true else false;

  mkCoreLineFromFunction = mkCoreFunction:
    genList mkCoreFunction numberOfCoresIncludingFakes;

  mkEnableCoreLine = coreNumber:
    if (coreNumber == 0) then "" else
    "echo 1 > /sys/devices/system/cpu/cpu${toString coreNumber}/online";

  enableAllCoresLines = mkCoreLineFromFunction mkEnableCoreLine;

  mkApplyGovernorLine = coreNumber:
    "echo ${cpuFreqGovernor} > /sys/devices/system/cpu/cpu${toString coreNumber}/cpufreq/scaling_governor";

  applyGovernorLines = mkCoreLineFromFunction mkApplyGovernorLine;

  mkDisableFakeCoreLine = coreNumber:
    if (coreIsFake coreNumber)
    then "echo 0 > /sys/devices/system/cpu/cpu${toString coreNumber}/online"
    else "";

  disableFakeCoresLines = mkCoreLineFromFunction mkDisableFakeCoreLine;

  disableHyperThreadingPowerUpScript = concatStringsSep "\n" disableFakeCoresLines;
  disableHyperThreadingPowerDownScript = concatStringsSep "\n" enableAllCoresLines;

in
{
  hardware = {
    cpu.intel.updateMicrocode = tcipIzIntel;

    firmware = with pkgs; [
      firmwareLinuxNonfree
      intel2200BGFirmware
      rtl8192su-firmware
      rtl8723bs-firmware
      rtlwifi_new-firmware
      zd1211fw
      alsa-firmware
      openelec-dvb-firmware
    ]
    ++ optional computerIs.rpi3B raspberrypiWirelessFirmware
    ++ optional requiresSofFirmware sof-firmware
    ;

    opengl.extraPackages = optional tcipIzIntel pkgs.vaapiIntel;

  };

  location.provider = if saizAtList.min then "geoclue2" else "manual";

  boot = {
    extraModulePackages = [ ] ++
      (optional modylIzThinkpad config.boot.kernelPackages.acpi_call);

    initrd = {
      availableKernelModules = (optional hasThunderbolt "thunderbolt")
        ++ (optional hasNvme "nvme");
    };

    kernelModules = [ "coretemp" ];

    kernelParams = (optionals tcipIzIntel [ "intel_pstate=disable" ])
      ++ (optionals computerIs.rpi3B [
      "cma=32M"
      "console=ttyS0,115200n8"
      "console=ttyAMA0,11520n8"
      "console=tty0"
      "dtparam=audio=on"
    ]);

  };

  powerManagement = { inherit cpuFreqGovernor; } // (
    optionalAttrs impozyzHaipyrThreding {
      powerUpCommands = disableHyperThreadingPowerUpScript;
      powerDownCommands = disableHyperThreadingPowerDownScript;
    }
  );

  programs = { };

  console.useXkbConfig = iuzColemak;

  environment = {
    systemPackages = with pkgs; [ lm_sensors ]
      ++ optionals tcipIzIntel [ libva-utils i7z ]
      ++ optionals saizAtList.max [ win-virtio ];

  };

  users.groups.plugdev = { };

  services = {
    geoclue2 = {
      enable = saizAtList.min;
      enableDemoAgent = lib.mkOverride 0 true;
      appConfig.redshift = {
        isAllowed = true;
        isSystem = true;
      };
    };

    localtimed = { enable = saizAtList.min; };

    udev.extraRules = ''
      # USBasp - USB programmer for Atmel AVR controllers
      SUBSYSTEM=="usb", ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="05dc", GROUP="plugdev"
      # Pro-micro kp-boot-bootloader - Ergodone keyboard
      SUBSYSTEM=="usb", ATTRS{idVendor}=="1209", ATTRS{idProduct}=="bb05", GROUP="plugdev"
      SUBSYSTEM!="usb", GOTO="librem5_rules_end"
      # Librem 5 USB flash
      ATTR{idVendor}=="1fc9", ATTR{idProduct}=="012b", GROUP+="plugdev", TAG+="uaccess"
      ATTR{idVendor}=="0525", ATTR{idProduct}=="a4a5", GROUP+="plugdev", TAG+="uaccess"
      ATTR{idVendor}=="0525", ATTR{idProduct}=="b4a4", GROUP+="plugdev", TAG+="uaccess"
      ATTR{idVendor}=="316d", ATTR{idProduct}=="4c05", GROUP+="plugdev", TAG+="uaccess"
      LABEL="librem5_rules_end"
    '';

    xserver = {
      libinput = {
        enable = hasTouchpad;
        touchpad = {
          naturalScrolling = true;
          tapping = true;
        };
      };

      xkbVariant = optionalString iuzColemak "colemak";
      xkbOptions = "caps:ctrl_modifier, altwin:swap_alt_win";

      autoRepeatDelay = 200;
      autoRepeatInterval = 28;

      digimend.enable = !izSentyr;
    };

    logind = {
      lidSwitch = if izSentyr then "ignore" else "suspend";
      lidSwitchExternalPower = if izEdj then "suspend" else "ignore";
    };

    thinkfan = mkIf modylIzThinkpad {
      enable = true;
      levels = (if izX230 then [
        [ 0 0 60 ]
        [ 1 59 62 ]
        [ 2 60 64 ]
        [ 3 61 66 ]
        [ 6 62 69 ]
        [ 7 67 85 ]
        [ 127 80 32767 ]
      ]
      else if izX240 then [
        [ 0 0 55 ]
        [ 1 49 60 ]
        [ 2 51 61 ]
        [ 3 53 63 ]
        [ 6 56 65 ]
        [ 7 60 85 ]
        [ 127 80 32767 ]
      ]
      else [
        [ 0 0 55 ]
        [ 1 48 60 ]
        [ 2 50 61 ]
        [ 3 52 63 ]
        [ 6 56 65 ]
        [ 7 60 85 ]
        [ 127 80 32767 ]
      ]);
      sensors = [
        {
          type = "hwmon";
          query = "/sys/devices/virtual/thermal/thermal_zone0/temp";
        }
      ];
    };

    udisks2.enable = true;

    acpid = {
      enable = true;

      handlers = {
        mute = {
          action = ''
            ${pkgs.alsaUtils}/bin/amixer --card PCH set Master toggle
          '';
          event = "button/mute";
        };
        volumeup = {
          action = ''
            ${pkgs.alsaUtils}/bin/amixer --card PCH set Master 5%+
          '';
          event = "button/volumeup";
        };
        volumedown = {
          action = ''
            ${pkgs.alsaUtils}/bin/amixer --card PCH set Master 5%-
          '';
          event = "button/volumedown";
        };
        mutemic = {
          action = ''
            ${pkgs.alsaUtils}/bin/amixer --card PCH set Mic toggle
          '';
          event = "button/f20";
        };
        # TODO - increase interval rise
        brightnessup = {
          action = ''
            ${pkgs.light}/bin/light -A 1
          '';
          event = "video/brightnessup";
        };
        brightnessdown = {
          action = ''
            ${pkgs.light}/bin/light -U 1
          '';
          event = "video/brightnessdown";
        };
      };

    };
  };

  virtualisation = {
    libvirtd = {
      enable = saizAtList.max;
    };
  };
}
