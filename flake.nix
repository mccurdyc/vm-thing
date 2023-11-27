{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.05";
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, disko, ... }: {

    nixosConfigurations.lvk = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ({modulesPath, ... }: {
            imports = [
              disko.nixosModules.disko
            ];
            disko.devices = import ./single-gpt-disk-fullsize-ext4.nix "/dev/sda";

            boot.loader.grub = {
              copyKernels = true;
              devices = [ "/dev/sda" ];
              efiInstallAsRemovable = true;
              efiSupport = true;
              enable = true;
              fsIdentifier = "label";
            };
            boot.loader.efi.efiSysMountPoint = "/boot/efi";
            boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "sd_mod" ];

            networking.hostName = "foo";
            networking.fqdn = "bar";

            networking.useDHCP = true;
            networking.interfaces."eth1".useDHCP = true;

            # Initial empty root password for easy login:
            services.openssh.permitRootLogin = "prohibit-password";

            users.users.root.openssh.authorizedKeys.keys = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO2cxynJf1jRyVzsOjqRYVkffIV2gQwNc4Cq4xMTcsmN"
            ];

            services.openssh.enable = true;

            system.stateVersion = "23.05";
          })
        ];
      };

  };
}
