{ config, pkgs, inputs, lib, ...}:

{
  imports = [
    inputs.dms.homeModules.dank-material-shell
    inputs.dms.homeModules.niri
    inputs.niri.homeModules.niri
    inputs.dms-plugin-registry.modules.default
  ];

  home.username = "yaku";
  home.homeDirectory = "/home/yaku";
  home.stateVersion = "25.11";
  programs.bash.enable = true;
  programs.home-manager.enable = true;
  news.display = "silent";
  
  programs.fish = {
    enable = true;
    functions = {
      _henshin_spinner = {
        body = ''
          set -l pid $argv[1]
          set -l frames "▱▱▱▱▱" "▰▱▱▱▱" "▰▰▱▱▱" "▰▰▰▱▱" "▰▰▰▰▱" "▰▰▰▰▰"
          tput civis # Hide cursor
          while kill -0 $pid 2>/dev/null
            for frame in $frames
              printf "\r\e[1;36m[\e[1;31m CHARGING \e[1;36m] \e[1;33m%s\e[0m " "$frame"
              sleep 0.1
              if not kill -0 $pid 2>/dev/null; break; end
            end
          end
          tput cnorm # Show cursor
          printf "\r\e[K"
        '';
      };
      henshin = {
        body = ''
          echo -e '\n📱 \033[1;31m[5-5-5] STANDING BY...\033[0m'
          home-manager switch -b backup-(date +%s) --flake ~/nixos-config#yaku &
          set -l pid $last_pid
          _henshin_spinner $pid
          wait $pid
          echo -e '\n✨ \033[1;31mCOMPLETE.\033[0m'
        '';
      };
      "henshin.ax" = {
        body = ''
          echo -e '\n⌚ \033[1;33mCOMPLETE.\033[0m \033[1;36mSTART UP.\033[0m'
          sudo nixos-rebuild switch --flake ~/nixos-config#Delta &
          set -l pid $last_pid
          _henshin_spinner $pid
          wait $pid
          echo -e '\n🔴 \033[1;31mTIME OUT.\033[0m \033[1;33mREFORMATION.\033[0m'
        '';
      };
    };
   	shellAliases = {
           clear = "command clear && fastfetch";
           ls = "eza --grid --icons --color=always --group-directories-first";
           ll = "eza --long --header --icons --git";
           # Steam (Software Rendering for UI - User confirmed Fix)
           steam = "env LIBGL_ALWAYS_SOFTWARE=1 steam";

           # 📸 Screenshot (Select area -> Edit in Swappy)
           screenshot = "grim -g \"$(slurp)\" - | swappy -f -";
           
           # 🐱 Bat looks better than cat
           cat = "bat";
           
           # 🔝 Btop is prettier than top
           top = "btop";
           
           # 🌲 Tree view
           lt = "eza --tree --level=2 --long --icons --git";
           
           # 📺 Pipes
           pipes = "pipes-rs";
        };
    interactiveShellInit = ''
      # Disable fish greeting
      set -g fish_greeting
      # Show fastfetch on terminal open
      fastfetch
    '';
  };

  # Fastfetch config
  xdg.configFile."fastfetch/config.jsonc".source = ./fastfetch.jsonc;

  # Ghostty terminal configuration
  programs.ghostty = {
    enable = true;
    settings = {
      theme = "tokyo-night";
      font-family = "JetBrainsMono Nerd Font";
      font-size = 10;
      background-opacity = 0.7;
      window-decoration = false;
      cursor-style = "bar";
    };
  };

  # Tokyo Night theme for Ghostty
  xdg.configFile."ghostty/themes/tokyo-night".text = ''
    background = 1a1b26
    foreground = c0caf5
    selection-background = 33467c
    selection-foreground = c0caf5
    cursor-color = c0caf5
    palette = 0=#15161e
    palette = 1=#f7768e
    palette = 2=#9ece6a
    palette = 3=#e0af68
    palette = 4=#7aa2f7
    palette = 5=#bb9af7
    palette = 6=#7dcfff
    palette = 7=#a9b1d6
    palette = 8=#414868
    palette = 9=#f7768e
    palette = 10=#9ece6a
    palette = 11=#e0af68
    palette = 12=#7aa2f7
    palette = 13=#bb9af7
    palette = 14=#7dcfff
    palette = 15=#c0caf5
  '';

  # ============================================
  # 💄 TERMINAL BEAUTIFICATION
  # ============================================
  
  # 🐱 Bat - Better cat
  programs.bat = {
    enable = true;
    config = {
      theme = "TwoDark";
      italic-text = "always";
    };
  };

  # 🔝 Btop - Better top
  programs.btop = {
    enable = true;
    settings = {
      color_theme = "tokyo-night";
      theme_background = false; # Transparent background if supported
      update_ms = 500;
    };
  };

  # 🔍 Fzf - Fuzzy finder (Ctrl+R, Ctrl+T)
  programs.fzf = {
    enable = true;
    enableFishIntegration = true;
    colors = {
      "fg" = "#c0caf5";
      "bg" = "#1a1b26";
      "hl" = "#bb9af7";
      "fg+" = "#c0caf5";
      "bg+" = "#292e42";
      "hl+" = "#7dcfff";
      "info" = "#7aa2f7";
      "prompt" = "#f7768e";
      "pointer" = "#7dcfff";
      "marker" = "#9ece6a";
      "spinner" = "#9ece6a";
      "header" = "#9ece6a";
    };
  };

  # ⚡ Zoxide - Smarter cd (z foldername)
  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
    options = ["--cmd cd"]; # Replace cd with z
  };

  # 📂 Yazi - Terminal File Manager
  programs.yazi = {
    enable = true;
    enableFishIntegration = true;
    # settings = { ... }; # Default settings are usually great
  };

  # 🎹 Cava - Audio Visualizer
  programs.cava = {
    enable = true;
    settings = {
      color = {
        background = "'#1a1b26'";
        foreground = "'#c0caf5'";
      };
    };
  };

  nixpkgs.config.allowUnfree = true;

  home.packages = with pkgs; [
    ripgrep
    brave
    (pkgs.writeShellApplication {
    name = "ns";
    runtimeInputs = with pkgs; [
      fzf
      nix-search-tv
    ];
    text = builtins.readFile "${pkgs.nix-search-tv.src}/nixpkgs.sh";
    })
    fishPlugins.tide
    tailscale-systray
    grim                    # Screenshot tool for Wayland
    slurp                   # Region selector for Wayland
    swappy                  # Screenshot editor (Wayland native)
    pkgs.vesktop
    obsidian
    antigravity
    eza
    peazip
    nmap
    wireshark
    
    # 🎨 MORE BEAUTY
    glow           # Beautiful markdown reader
    peaclock       # Binary clock
    cbonsai        # Grow a tree in your terminal
    pipes-rs       # 3D pipes screensaver
    cava           # Audio visualizer (if not using hm module, useful for quick launch)
    
    # ============================================
    # 🎯 CURSOR THEMES
    # ============================================
    bibata-cursors          # Modern flat cursors
    capitaine-cursors       # macOS-style cursors
    catppuccin-cursors      # Catppuccin themed cursors
    google-cursor           # Google's Material cursors
    
    # ============================================
    # 🎨 ICON THEME (pick ONE - they conflict!)
    # ============================================
    papirus-icon-theme      # ✅ Currently active
    # candy-icons           # Colorful gradient icons
    # qogir-icon-theme      # Clean dark icons  
    # colloid-icon-theme    # Dark mode friendly
    # whitesur-icon-theme   # macOS Big Sur style
    
    # ============================================
    # 📁 FILE MANAGER & TOOLS
    # ============================================
    nautilus                # File manager - uses GTK theming automatically!
    loupe                   # Image viewer - GNOME's modern viewer
    nwg-look                # 🖥️ GUI to change icon themes
    distrobox               # 📦 Use any Linux distro inside your terminal
    copyq                   # 📋 Advanced clipboard manager with pinning
    pavucontrol             # 🔊 Audio volume control (works with Pipewire)
    helvum                  # 🕸️ Pipewire patchbay GUI
  ];

  # ============================================
  # �️ CURSOR THEME (Global Enforcement)
  # ============================================
  home.pointerCursor = {
    gtk.enable = true;
    x11.enable = true;
    name = "Bibata-Modern-Ice";
    package = pkgs.bibata-cursors;
    size = 24;
  };

  # ============================================
  # �🖼️ GTK THEMING (for GTK apps)
  # ============================================
  qt = {
    enable = true;
    platformTheme.name = "gtk";
    style.name = "adwaita-dark";
  };

  # Override Steam Desktop Entry (Software Rendering Fix)
  xdg.desktopEntries.steam = {
    name = "Steam (Software Render)";
    exec = "env LIBGL_ALWAYS_SOFTWARE=1 steam %U";
    icon = "steam";
    terminal = false;
    type = "Application";
    categories = [ "Network" "FileTransfer" "Game" ];
    mimeType = [ "x-scheme-handler/steam" "x-scheme-handler/steamlink" ];
  };

  gtk = {
    enable = true;
    iconTheme = {
      # 🎨 CHANGE THIS to switch your icon theme!
      # Options: "Papirus", "Papirus-Dark", "Papirus-Light",
      #          "Tela", "Tela-dark", "Tela-circle", "Tela-circle-dark",
      #          "candy-icons", "Numix", "Numix-Circle",
      #          "Qogir", "Qogir-dark", "Colloid", "Colloid-dark",
      #          "WhiteSur", "WhiteSur-dark", "Fluent", "Moka",
      #          "Zafiro-Icons", "breeze"
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
  };




  # ============================================
  # 🖼️ DEFAULT APPLICATIONS
  # ============================================
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      # Images -> Loupe
      "image/png" = [ "org.gnome.Loupe.desktop" ];
      "image/jpeg" = [ "org.gnome.Loupe.desktop" ];
      "image/gif" = [ "org.gnome.Loupe.desktop" ];
      "image/webp" = [ "org.gnome.Loupe.desktop" ];
      "image/svg+xml" = [ "org.gnome.Loupe.desktop" ];
      "image/bmp" = [ "org.gnome.Loupe.desktop" ];
      "image/tiff" = [ "org.gnome.Loupe.desktop" ];
      # File manager
      "inode/directory" = [ "org.gnome.Nautilus.desktop" ];
    };
  };
  # Force overwrite existing mimeapps.list files
  xdg.configFile."mimeapps.list".force = true;

  # niri settings - DMS includes system will include this as hm.kdl
  programs.niri.settings = {
    outputs."eDP-1" = {
      mode = {
        width = 1366;
        height = 768;
      };
      scale = 1.0;
    };
    prefer-no-csd = true;
    input.focus-follows-mouse.enable = true;
    
    layout = {
      gaps = 8;
      focus-ring.enable = false;
      border.enable = false;
    };
    
    hotkey-overlay.skip-at-startup = true;
    
    # Your custom keybinds
    binds = {
      "Alt+Space".action.spawn = [ "ghostty" ];
      "Mod+E".action.spawn = [ "nautilus" ];  # File manager
      "Mod+Q".action.close-window = [];
      "Mod+Left".action.focus-column-left = [];
      "Mod+Slash".action.switch-preset-column-width = [];
      "Mod+Period".action.maximize-column = [];
      "Mod+F".action.fullscreen-window = []; # Added proper Fullscreen toggle
    };

    window-rules = [
      {
        # Force Steam games to be fullscreen/maximized automatically
        matches = [{ title = "^Umamusume$"; }]; 
        default-column-width = { proportion = 1.0; };
        open-maximized = true;
      }
      {
        matches = [{ app-id = "^com\\.github\\.hluk\\.copyq$"; }];
        open-floating = true;
        default-floating-position = { x = 32; y = 32; relative-to = "top-right"; };
      }
      {
        matches = [
          { app-id = "^com-abdownloadmanager-desktop-AppKt$"; }
          { app-id = "^ABDownloadManager$"; }
        ];
        draw-border-with-background = false;
        geometry-corner-radius = {
          bottom-left = 12.0;
          bottom-right = 12.0;
          top-left = 12.0;
          top-right = 12.0;
        };
        clip-to-geometry = true;
      }
    ];
  };

  # xdg.configFile."niri/config.kdl" = pkgs.lib.mkForce {
  #     source = config.lib.file.mkOutOfStoreSymlink "/home/yaku/nixos-config/niri.kdl";
  #   };
    
  programs.dank-material-shell = {
    enable = true;
    enableSystemMonitoring = true;
    dgop.package = inputs.dgop.packages.${pkgs.system}.default;
    niri = {
      enableKeybinds = true;   # Use static keybinds
      enableSpawn = true;      # Auto-start DMS with niri
      includes = {
        enable = true;
        override = false;
        filesToInclude = [
          "alttab"
          "binds"
          "colors"
          "cursor"
          "layout"
          "outputs"
          # wpblur excluded - blur works better without include
        ];
      };
    };
    plugins = {
        # Simply enable plugins by their ID (from the registry)
        dankBatteryAlerts.enable = true;
        #bluetoothManager.enable = true;
        #dockerManager.enable = true;
        
        # Add plugin-specific settings
        # mediaPlayer = {
        #   enable = true;
        #
        #   # You can only define settings here if using the home-manager module
        #   settings = {
        #     preferredSource = "spotify";
        #   };
        # };
      };
    };
  
  # Pre-create DMS config files to prevent Niri crash on fresh install
  home.activation.createDmsFiles = lib.hm.dag.entryAfter ["writeBoundary"] ''
    mkdir -p $HOME/.config/niri/dms
    for file in alttab binds colors cursor layout outputs wpblur; do
      if [ ! -f "$HOME/.config/niri/dms/$file.kdl" ]; then
        touch "$HOME/.config/niri/dms/$file.kdl"
      fi
    done
  '';

  systemd.user.services.tailscale-systray = {
    Unit = {
      Description = "Tailscale System Tray";
      After = [ "graphical-session-pre.target" "copyq.service" ];
      Wants = [ "copyq.service" ];
      PartOf = [ "graphical-session.target" ];
    };

    Install = {
      WantedBy = [ "graphical-session.target" ];
    };

    Service = {
      ExecStart = "${pkgs.tailscale-systray}/bin/tailscale-systray";
      Restart = "on-failure";
    };
  };

  # 🚀 Distrobox Warmup (Keeps the container running for instant app launches)
  systemd.user.services.distrobox-arch-warmup = {
    Unit = {
      Description = "Warm up Arch Distrobox container";
      After = [ "graphical-session-pre.target" ];
      PartOf = [ "graphical-session.target" ];
    };

    Install = {
      WantedBy = [ "graphical-session.target" ];
    };

    Service = {
      # Running true inside the container starts it and stays active
      ExecStart = "${pkgs.distrobox}/bin/distrobox enter arch -- true";
      Type = "oneshot";
      RemainAfterExit = true;
    };
  };

  systemd.user.services.distrobox-gentoo-warmup = {
    Unit = {
      Description = "Warm up Gentoo Distrobox container";
      After = [ "graphical-session-pre.target" ];
      PartOf = [ "graphical-session.target" ];
    };

    Install = {
      WantedBy = [ "graphical-session.target" ];
    };

    Service = {
      ExecStart = "${pkgs.distrobox}/bin/distrobox enter gentoo -- true";
      Type = "oneshot";
      RemainAfterExit = true;
    };
  };

  # 📋 Clipboard Manager (CopyQ)
  systemd.user.services.copyq = {
    Unit = {
      Description = "CopyQ clipboard manager";
      After = [ "graphical-session-pre.target" ];
      PartOf = [ "graphical-session.target" ];
    };

    Install = {
      WantedBy = [ "graphical-session.target" ];
    };

    Service = {
      ExecStart = "${pkgs.copyq}/bin/copyq";
      Restart = "on-failure";
    };
  };
  
  #xdg.configFile."niri/config.kdl".source = ./niri.kdl; 
  #xdg.configFile."quickshell".source = ./quickshell; #need to on it later
  home.sessionVariables = {
    # Quickshell
    QML2_IMPORT_PATH = "${pkgs.quickshell}/lib/qt-6/qml";
    
    # Default terminal
    TERMINAL = "ghostty";
    
    # DMS icon theme (reads from GTK settings, but can override here)
    QS_ICON_THEME = "Papirus-Dark";
  };
}
