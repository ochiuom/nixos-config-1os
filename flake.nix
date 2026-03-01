{
  description = "ochinix-pc NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    lanzaboote = {
      url = "github:nix-community/lanzaboote/v1.0.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # 🔥 Disko (Declarative Disk Management)
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, lanzaboote, home-manager, disko, ... }: {
    nixosConfigurations.ochinix-pc = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";

      modules = [
        # 🔥 Disko must come first
        disko.nixosModules.disko
        ./disko.nix

        ./hardware-configuration.nix
        ./configuration.nix

        lanzaboote.nixosModules.lanzaboote
        home-manager.nixosModules.home-manager

        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.ochinix = import ./home.nix;
          home-manager.backupFileExtension = "backup";
          nixpkgs.config.allowUnfree = true;
        }
      ];
    };
  };
}
