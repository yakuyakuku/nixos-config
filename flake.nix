{
	description = "Nix OS Flake Config";
	inputs = {
		nixpkgs.url = "nixpkgs/nixos-unstable";
		home-manager = {
			url = "github:nix-community/home-manager";
			inputs.nixpkgs.follows = "nixpkgs";
		};
		dms = {
		      url = "github:AvengeMedia/DankMaterialShell/stable";
		      inputs.nixpkgs.follows = "nixpkgs";
		};
		niri = {
		  url = "github:sodiboo/niri-flake";
		  inputs.nixpkgs.follows = "nixpkgs";
		};
		dgop = {
		      url = "github:AvengeMedia/dgop";
		      inputs.nixpkgs.follows = "nixpkgs";
		    };
		
	};

	outputs = { self, nixpkgs, home-manager, ... }@inputs: {
	    nixosConfigurations.Delta = nixpkgs.lib.nixosSystem {
	        system = "x86_64-linux";
	        specialArgs = { inherit inputs; };
	        modules = [
	            ./configuration.nix
	            # NOT using inputs.niri.nixosModules.niri - it provides niri 25.08
	            # Using nixpkgs niri (25.11) via programs.niri.enable in configuration.nix
	            # This is required for the DMS 'includes' feature to work
	            home-manager.nixosModules.home-manager
	            {
	                home-manager = {
	                    useGlobalPkgs = true;
	                    useUserPackages = true;
	                    extraSpecialArgs = { inherit inputs; };
	                    users.yaku = import ./home.nix;
	                    backupFileExtension = "backup";            
	                };
	            }
	        ];
	    };
	};
}
