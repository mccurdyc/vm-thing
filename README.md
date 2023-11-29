# nixos-anywhere

## Info

### Base Image

- `ubuntu-2310-mantic-amd64-v20231031`

### Disk

```bash
lsblk
...
sda
├─sda1  ext4   1.0   cloudimg-rootfs 7de4422f-ae5a-4c26-86eb-b556659985fa   45.4G     4% /snap
│                                                                                        /
├─sda14
├─sda15 vfat   FAT32 UEFI            8775-A559                              98.3M     6% /boot/efi
└─sda16 ext4   1.0   BOOT            17cb1bb3-7ff7-4880-a4fa-f06a3b636de7  759.8M     7% /boot
```

(after nixos-anywhere / disko)

```bash
[root@nixos:~]# lsblk -f
NAME    FSTYPE   FSVER LABEL           UUID                                 FSAVAIL FSUSE% MOUNTPOINTS
loop0   squashfs 4.0                                                              0   100% /nix/.ro-store
sda
├─sda1  ext4     1.0   cloudimg-rootfs 7de4422f-ae5a-4c26-86eb-b556659985fa
├─sda14
├─sda15 vfat     FAT32 UEFI            8775-A559
└─sda16 ext4     1.0   BOOT            17cb1bb3-7ff7-4880-a4fa-f06a3b636de7
```

- Why are they not mounted where I've specified?

```bash
[root@nixos:~]# cat /etc/nixos/configuration.nix
{ config, pkgs, ... }:

{
  imports = [  ];
}
```

- Why doesn't the target machine get the configuration I specify in my flake?

> The new server's configurations are defined in the flake. nixos-anywhere does not create etc/nixos/configuration.nix, since it expects the server to be administered remotely.

    - Seems like it's just using the nixos-anywhere "no configuration".

Oh this is expected. `nixos-anywhere` command doesn't do anything with the flake, just gets the nixos installer.

On target

2. `nix shell 'nixpkgs#git`
3. `nixos-rebuild switch --verbose --flake 'git+https://github.com/mccurdyc/vm-thing.git#lvk'

Why is this erroring?

```bash
at /nix/store/7fkwd086mmlkpmsk1xyn23h4rlak8qrz-source/lib/customisation.nix:143:45: (source not available)
error: getting status of '/nix/store/7fkwd086mmlkpmsk1xyn23h4rlak8qrz-source': No such file or directory
```

Tried

- `nix-channel --update`
- `nix flake update` (no git diff after, but does this force it to "fetch" flake inputs?). Should I use `nix flake prefetch`?


## Commands

### Create plain Ubuntu machine

```bash
gcloud compute instances create instance-2 \
    --zone=us-central1-b \
    --machine-type=n2d-standard-4 \
    --network-interface=network-tier=PREMIUM,stack-type=IPV4_ONLY,subnet=subnet-us-central1-01 \
    --maintenance-policy=MIGRATE \
    --provisioning-model=STANDARD \
    --service-account=cmccurdy-main@dataeng-cmccurdy-sandbox-b81d.iam.gserviceaccount.com \
    --scopes=https://www.googleapis.com/auth/cloud-platform \
    --create-disk=auto-delete=yes,boot=yes,device-name=instance-2,image=projects/ubuntu-os-cloud/global/images/ubuntu-2310-mantic-amd64-v20231031,mode=rw,size=50,type=projects/dataeng-cmccurdy-sandbox-b81d/zones/us-central1-b/diskTypes/pd-ssd \
    --no-shielded-secure-boot \
    --shielded-vtpm \
    --shielded-integrity-monitoring \
    --labels=goog-ec-src=vm_add-gcloud \
    --reservation-affinity=any
```

### Delete machine

```bash
gcloud compute instances delete instance-2
```

### nixos-anywhere

```bash
nix run github:nix-community/nixos-anywhere -- \
    --print-build-logs \
    --no-reboot \
    --debug \
    --build-on-remote \
    -i ~/.ssh/id_ed25519 \
    --ssh-port 2222 \
    root@localhost \
    --flake '.#lvk'
```

- Why doesn't this work to run twice?

### Start IAP tunnel

```bash
gcloud compute start-iap-tunnel instance-2 22 \
    --local-host-port=localhost:2222 \
    --zone=us-central1-b
```

Test via `ssh root@localhost -p 2222`.
