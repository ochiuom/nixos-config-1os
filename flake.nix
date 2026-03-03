{
  description = "ochinix-pc NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

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

  outputs = { self, nixpkgs, home-manager, disko, ... }: {
    nixosConfigurations.ochinix-pc = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";

      modules = [
        # 🔥 Disko must come first
        disko.nixosModules.disko
        ./disko_1os.nix

        ./hardware-configuration.nix
        ./configuration.nix

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
