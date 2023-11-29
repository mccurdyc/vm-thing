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
