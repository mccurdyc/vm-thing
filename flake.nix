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
              fsIdentifier = "uuid";
              version = 2;
            };
            boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "sd_mod" "kvm_intel"];

            nixpkgs.hostPlatform = "x86_64-linux";
            powerManagement.cpuFreqGovernor = "ondemand";
            hardware.cpu.intel.updateMicrocode = true;
            hardware.enableRedistributableFirmware = true;

            networking.hostName = "foo";
            networking.fqdn = "bar";

            # Most of this is inspired by existing scripts:
            # https://github.com/nix-community/nixos-install-scripts/tree/master/hosters/hetzner-dedicated

            networking.useDHCP = true;
            networking.interfaces."eno1".useDHCP = true;

            # Initial empty root password for easy login:
            services.openssh.permitRootLogin = "prohibit-password";

            users.users.root.openssh.authorizedKeys.keys = [
              "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC1QQL5UFDe3mz2K/XlWmAXKbSOhqZDlHpT4oACl0WK6MVFeulQRE2Gzb0r2Q3yj8svQx2MQMa9x+mRLhzZubBVevdEY4APOzqQZ+A/y0quAiUHlDe5BtenWbaXEVu4r2kYXYVVy85nwSlnUf7c+JGJXzJZ/7+4AXsM8iPComg7VtS22BXcnJYt6oWl+WxkFJQc7WzE5RIEcPZgpD/bZ5FQ5zWXguIkZoYx/g/G9+CvV79B+e1YFzuNxrpXd0tMPvQaTbyHt3Ryaz3RDeBQ8jYcACKscNAQ+b7Hu2N2/2UdgMbGvbSyAzfQ6cmPuKoUVV1hF4fTuRhq5cdP1ntaw0DcRi+AvoG6vENfkSuFhQNXN8tZh4RydR4EXfOy3MGdLQyvnv+LYji2GVN0JmimG1eMbm4c+G7fVBYqp11f049jdRxce3X0jiS2P5wM/MZq7KAZmSeyac59S2Nvc/l77IYCOvi+abbqDSPx4RcoQ6JYh81hOkbR9tYyD2m7eaU5m2FH0+KALaPc6XNtuhMYwrEB62zBizxyGcBoavCqmk8butMZkTcI6bQOiwA8AIIXPGHvO4MxfFmBwSl10Q4wZ59JDTTdzc2vuTUJORMbh6qXJraSYA+wLkQKb9PmvlXz4LVbXS4fCJNZ+9BjbtjDRns4RH7F282myXvMDlLBwPo7BQ=="
            ];

            services.openssh.enable = true;

            system.stateVersion = "23.05";
          })
        ];
      };

  };
}
