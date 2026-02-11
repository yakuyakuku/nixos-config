# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, inputs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      inputs.dms.nixosModules.greeter
    ];
    
  # Allow unfree packages (Steam, etc.)
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.nvidia.acceptLicense = true;
  # Use systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  
  # Enable Nvidia Framebuffer (Fixes some Wayland issues)
  boot.kernelParams = [ "quiet" "splash" ];

  boot.loader.systemd-boot.configurationLimit = 10;

  networking.hostName = "Delta"; # Define your hostname.

  # Configure network connections interactively with nmcli or nmtui.
  # networking.wireless.enable = true;
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Asia/Jakarta";

  # niri is enabled via inputs.niri.nixosModules.niri in flake.nix
  programs.niri.enable = true;
  services.tailscale.enable = true;
  # Disable niri-flake's polkit agent to use DMS's built-in one
  systemd.user.services.niri-flake-polkit.enable = false;
  
  environment.pathsToLink = [ "/share/applications" "/share/xdg-desktop-portal" ];

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkb.options in tty.
  # };

  # Enable the X11 windowing system.
  # services.xserver.enable = true;
  xdg.mime = {
    enable = true;
    defaultApplications = {
      "application/zip" = "peazip.desktop";
      "application/x-tar" = "peazip.desktop";
      "application/x-7z-compressed" = "peazip.desktop";
      "application/x-rar" = "peazip.desktop";
    };
    addedAssociations = {
      "application/zip" = "peazip.desktop";
    };
  };
  

  # Configure keymap in X11
  # services.xserver.xkb.layout = "us";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";

  # Enable CUPS to print documents.
  services.printing.enable = true;
  services.printing.browsing = true;
  services.printing.browsed.enable = true;

  # Enable Avahi for network printer discovery.
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };


  services.spice-vdagentd.enable = true;

  # Enable Podman (Required for Distrobox)
  virtualisation.podman.enable = true;

  # Enable RTKit for Pipewire real-time performance
  security.rtkit.enable = true;
  services.pipewire = {
     enable = true;
     alsa.enable = true;
     alsa.support32Bit = true;
     pulse.enable = true;
     jack.enable = true;
   };

  # Enable Bluetooth
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        Experimental = true;
      };
    };
  };

  # Enable touchpad support (enabled default in most desktopManager).
  services.libinput.enable = true;

  # services.getty.autoLoginUser = "yaku"

  # services.displayManager.sddm.enable = true;
  # services.displayManager.sddm.wayland.enable = true;

  # Enable Dank Greeter (DMS Login Screen)
  programs.dank-material-shell.greeter = {
    enable = true;
    compositor.name = "niri";
    # Sync theme settings from user's home
    configHome = "/home/yaku";
    # Point to the session config for wallpaper
    configFiles = [
      ./greeter/session.json
      ./greeter/memory.json
    ];
  };

  # ============================================
  # 🎮 GRAPHICS & NVIDIA DRIVERS
  # ============================================
  # Enable OpenGL
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      intel-media-driver
    ];
  };

  # Load specific driver
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    # Modesetting is required (especially for Wayland)
    modesetting.enable = true;
    
    # Power management (can help with sleep/suspend and memory allocation)
    powerManagement.enable = false;
    powerManagement.finegrained = false;

    # Do not use open source kernel modules (Maxwell doesn't support them well)
    open = false;

    # Disable Nvidia settings menu (Datacenter drivers don't support it)
    nvidiaSettings = false;

    # Switch to 570 branch driver
    package = config.boot.kernelPackages.nvidiaPackages.dc_570;

    # Prime Configuration (Hybrid Graphics)
    prime = {
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };
      
      # Sync Mode (Discrete only) - Causes Steam Black Screen on Wayland
      sync.enable = false;
      
      # Bus IDs (found via lspci)
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.yaku = {
      isNormalUser = true;
      shell = pkgs.fish;
      extraGroups = [ "wheel" "bluetooth" "lp" "networkmanager" ]; # Enable ‘sudo’ and hardware control.
      packages = with pkgs; [
       tree
     ];
   };

   security.sudo.extraRules = [
     {
       users = [ "yaku" ];
       commands = [
         {
           command = "/run/current-system/sw/bin/nixos-rebuild";
           options = [ "NOPASSWD" ];
         }
       ];
     }
   ];

  # Allow NetworkManager to be managed by members of the networkmanager group
  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if ((action.id == "org.freedesktop.NetworkManager.network-control" ||
           action.id == "org.freedesktop.NetworkManager.settings.modify.system" ||
           action.id == "org.freedesktop.NetworkManager.settings.modify.own" ||
           action.id == "org.freedesktop.NetworkManager.settings.modify.hostname" ||
           action.id == "org.freedesktop.NetworkManager.settings.modify.global-dns" ||
           action.id == "org.freedesktop.NetworkManager.wifi.share.open" ||
           action.id == "org.freedesktop.NetworkManager.wifi.share.protected") &&
          subject.isInGroup("networkmanager")) {
        return polkit.Result.YES;
      }
    });
  '';

  programs.firefox.enable = true;
  
  # ============================================
  # 🎮 STEAM
  # ============================================
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;      # Steam Remote Play
    dedicatedServer.openFirewall = true; # Dedicated server
    localNetworkGameTransfers.openFirewall = true;
  };

  programs.gamescope.enable = true;

  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).
  environment.systemPackages = with pkgs; [
     vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
     wget
     micro
     git
     alacritty
     ghostty
     # Override Quickshell to force enable LayerShell support
     (pkgs.quickshell.overrideAttrs (oldAttrs: {
       cmakeFlags = (oldAttrs.cmakeFlags or []) ++ [ "-DWAYLAND_WLR_LAYERSHELL=ON" ];
       nativeBuildInputs = (oldAttrs.nativeBuildInputs or []) ++ [ pkgs.wayland-protocols pkgs.wayland-scanner ];
       buildInputs = (oldAttrs.buildInputs or []) ++ [ pkgs.qt6.qtwayland ];
     }))
     wl-clipboard
     rofi
     swaybg
     xwayland-satellite
     lazygit
     btop
     fastfetch
     fish
     protonplus           # GUI to manage Proton/Wine versions for Steam
     bibata-cursors       # Required for Regreet theme
     papirus-icon-theme   # Required for Regreet theme
     gnome-themes-extra   # Adwaita Dark theme support
     cage                 # Compositor for Regreet
     regreet              # Login Screen
   ];



   programs.fish.enable = true;

   fonts.packages = with pkgs; [
   	nerd-fonts.jetbrains-mono
   ];

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    warn-dirty = false;
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "25.11"; # Did you read the comment?

}
