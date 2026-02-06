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
	programs.bash = {
	    enable = true;
	    shellAliases = {
	      # The "Henshin" Transformation Sequence
	      henshin = "echo -e '\\n🛑 \\033[1;33mSTANDBY...\\033[0m' && sudo nixos-rebuild switch --flake ~/nixos-config && echo -e '\\n✨ \\033[1;36mCOMPLETE.\\033[0m \\033[1;35mCHANGING!\\033[0m 🦋\\n'";
	    };
	    initExtra = ''
	      # Run fastfetch on terminal open
	      fastfetch
	    '';
	  };

	# Starship prompt - beautiful shell prompt with icons
	programs.starship = {
	  enable = true;
	  settings = {
	    add_newline = false;
	    format = "$nix_shell$directory$git_branch$git_status$fill$time$line_break$character";
	    fill.symbol = " ";
	    directory = {
	      style = "blue bold";
	      truncation_length = 3;
	      truncate_to_repo = false;
	    };
	    git_branch = {
	      symbol = " ";
	      style = "purple";
	    };
	    git_status.style = "yellow";
	    nix_shell = {
	      symbol = " ";
	      style = "cyan";
	    };
	    time = {
	      disabled = false;
	      format = "[$time]($style) ";
	      style = "white dimmed";
	      time_format = "%I:%M:%S %p";
	    };
	    character = {
	      success_symbol = "[❯](green)";
	      error_symbol = "[❯](red)";
	    };
	  };
	};

	# Ghostty terminal configuration
	programs.ghostty = {
	  enable = true;
	  settings = {
	    theme = "catppuccin-mocha";
	    font-family = "JetBrainsMono Nerd Font";
	    font-size = 12;
	    background-opacity = 0.9;
	    window-decoration = false;
	    cursor-style = "bar";
	  };
	};

	home.packages = with pkgs; [
	  ripgrep
	  brave
	  starship
	];

	# niri settings
	programs.niri.settings = {
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
	    center-focused-column = "never";
	  };
	  binds = {
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
	    enableKeybinds = true;   # Static keybinds managed by Nix (NixOS-friendly)
	    enableSpawn = true;      # Auto-start DMS with niri
	    includes.enable = false; # Disable includes - requires writable fs, conflicts with NixOS
	  };
	};

	
	#xdg.configFile."niri/config.kdl".source = ./niri.kdl;	
	#xdg.configFile."quickshell".source = ./quickshell; #need to on it later
	home.sessionVariables = {
	  QML2_IMPORT_PATH = "${pkgs.quickshell}/lib/qt-6/qml";
	  TERMINAL = "ghostty";  # Default terminal
	};
}
