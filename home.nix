{ config, pkgs, inputs, ...}:

{

	imports = [
			inputs.dms.homeModules.dank-material-shell
			inputs.dms.homeModules.niri
			inputs.niri.homeModules.niri  # Required for DMS niri integration
		];

	home.username = "yaku";
	home.homeDirectory = "/home/yaku";
	home.stateVersion = "25.11";
	programs.bash.enable = true;

	programs.fish = {
	  enable = true;
	  shellAliases = {
	    henshin = "echo -e '\\\\n🛑 \\\\033[1;33mSTANDBY...\\\\033[0m' && sudo nixos-rebuild switch --flake ~/nixos-config && echo -e '\\\\n✨ \\\\033[1;36mCOMPLETE.\\\\033[0m \\\\033[1;35mCHANGING!\\\\033[0m 🦋\\\\n'";
	    clear = "command clear && fastfetch";
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
	    font-size = 12;
	    background-opacity = 0.5;
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

	home.packages = with pkgs; [
	  ripgrep
	  brave
	  fishPlugins.tide
	];

	# niri settings - DMS includes system will include this as hm.kdl
	programs.niri.settings = {
	  # Output config (VM specific - adjust for your display)
	  outputs."Virtual-1" = {
	    mode = {
	      width = 1920;
	      height = 1080;
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
	  
	  # Layer rule for DMS blur wallpaper
	  layer-rules = [
	    {
	      matches = [{ namespace = "dms:blurwallpaper"; }];
	      block-out-from = "screen-capture";
	    }
	  ];
	  
	  spawn-at-startup = [
	    { command = [ "systemctl" "--user" "start" "dms" ]; }
	  ];
	  
	  # Your custom keybinds
	  binds = {
	    "Mod+Space".action.spawn = [ "dms-launcher" ];
	    "Alt+Space".action.spawn = [ "ghostty" ];
	    "Mod+Q".action.close-window = [];
	    "Mod+Left".action.focus-column-left = [];
	    "Mod+Right".action.focus-column-right = [];
	    "Mod+Slash".action.switch-preset-column-width = [];
	    "Mod+Period".action.maximize-column = [];
	  };
	};

	  # xdg.configFile."niri/config.kdl" = pkgs.lib.mkForce {
	  # 		source = config.lib.file.mkOutOfStoreSymlink "/home/yaku/nixos-config/niri.kdl";
	  # 	};
	  
	programs.dank-material-shell = {
	  enable = true;
	  enableSystemMonitoring = true;
	  dgop.package = inputs.dgop.packages.${pkgs.system}.default;
	  niri = {
	    enableKeybinds = false;  # Don't use static keybinds, use includes instead
	    enableSpawn = true;      # Auto-start DMS with niri
	    includes = {
	      enable = true;         # Enable config includes (fixes cursor issue)
	      override = true;       # DMS settings take priority
	      filesToInclude = [
	        "alttab"
	        "binds"
	        "colors"
	        "cursor"             # This fixes the cursor theme issue!
	        "layout"
	        "outputs"
	        "wpblur"
	      ];
	    };
	  };
	};

	
	#xdg.configFile."niri/config.kdl".source = ./niri.kdl;	
	#xdg.configFile."quickshell".source = ./quickshell; #need to on it later
	home.sessionVariables = {
	  QML2_IMPORT_PATH = "${pkgs.quickshell}/lib/qt-6/qml";
	  TERMINAL = "ghostty";  # Default terminal
	};
}
