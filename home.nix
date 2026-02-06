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
	      # 1. Prints "STANDBY" in Yellow
	      # 2. Runs the rebuild (No password needed)
	      # 3. If successful (&&), prints "COMPLETE. CHANGING" in Cyan/Magenta
  	      henshin = "echo -e '\\n🛑 \\033[1;33mSTANDBY...\\033[0m' && sudo nixos-rebuild switch --flake ~/nixos-config && echo -e '\\n✨ \\033[1;36mCOMPLETE.\\033[0m \\033[1;35mCHANGING!\\033[0m 🦋\\n'";
	    };
	 };
	home.packages = with pkgs; [
	  ripgrep
	  brave	
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
