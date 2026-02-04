{ config, pkgs, ...}:

{
	home.username = "yaku";
	home.homeDirectory = "/home/yaku";
	home.stateVersion = "25.11";
	programs.bash = {
		enable = true;
		shellAliases = {
			henshin = "Stand By, Complete. CHANGING";
		};
	};
	home.packages = with pkgs; [
	  btop
	  ripgrep
	  fastfetch
	  lxqt.pcmanfm-qt
	  brave	
	];	
	
}
