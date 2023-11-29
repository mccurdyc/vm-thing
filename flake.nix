{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = inputs@{ nixpkgs, disko, flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        # systems for which you want to build the `perSystem` attributes
        "x86_64-linux"
        "aarch64-darwin"
      ];

      perSystem = { config, pkgs, system, ... }: {
        formatter = pkgs.nixpkgs-fmt;
        devShells.default = import ./shell.nix { inherit pkgs system; };
      };

      flake = {
        nixosConfigurations.lvk = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            disko.nixosModules.disko
            ./configuration.nix
          ];
        };
      };
    };
}
