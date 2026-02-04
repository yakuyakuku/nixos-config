{ config, pkgs, ...}:

{
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
	  btop
	  ripgrep
	  fastfetch
	  lxqt.pcmanfm-qt
	  brave	
	];
	xdg.configFile."niri/config.kdl".source = ./niri.kdl;	
	xdg.configFile."quickshell".source = ./quickshell;
}
