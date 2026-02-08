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
    dms-plugin-registry = {
      url = "github:AvengeMedia/dms-plugin-registry";
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
    nix-monitor = {
      url = "github:antonjah/nix-monitor";
    };
  };

  outputs = { self, nixpkgs, home-manager, nix-monitor, ... }@inputs: {
    
    # --- SYSTEM CONFIGURATION (Run with: henshin.ax) ---
    nixosConfigurations.Delta = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [
        ./configuration.nix
        # Note: home-manager module is REMOVED from here.
      ];
    };

    # --- USER CONFIGURATION (Run with: henshin) ---
    homeConfigurations."yaku" = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      extraSpecialArgs = { inherit inputs; };
      modules = [
        ./home.nix
        
        # Nix Monitor is now correctly placed here
        nix-monitor.homeManagerModules.default
        {
          programs.nix-monitor = {
            enable = true;
            # Track both System and Home Manager generations
            generationsCommand = [ 
              "sh" "-c" "echo $(( $(ls -1d /nix/var/nix/profiles/system-*-link 2>/dev/null | wc -l) + $(ls -1d /home/yaku/.local/state/nix/profiles/home-manager-*-link 2>/dev/null | wc -l) ))"
            ];
            # This rebuilds ONLY your user config
            rebuildCommand = [ 
              "home-manager" "switch" "--flake" "/home/yaku/nixos-config#yaku"
            ];
          };
        }
      ];
    };
  };
}
