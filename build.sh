#!/bin/bash

path=$(pwd)

# curl -L http://downloads.raspberrypi.org/raspios_arm64/images/raspios_arm64-2020-08-24/2020-08-20-raspios-buster-arm64.zip --output raspios-buster-arm64.zip

# unzip raspios-buster-arm64.zip

boot_size=$(sudo parted  2020-08-20-raspios-buster-arm64.img  -s print | grep fat32 | tr -s [:blank:] | cut -d " " -f4)
root_size=$(sudo parted  2020-08-20-raspios-buster-arm64.img  -s print | grep ext4 | tr -s [:blank:] | cut -d " " -f4)
echo root_size=$root_size
echo boot_size=$boot_size

sudo kpartx -av 2020-08-20-raspios-buster-arm64.img

sudo mkdir /media/PI_BOOT
sudo mount /dev/mapper/loop0p1 /media/PI_BOOT/
cd /media/PI_BOOT/
sudo bsdtar --numeric-owner --format gnutar -cpf /tmp/boot.tar .
boot_tarball_size=$(ls /tmp/boot.tar -l --block-size=1MB |  tr -s [:blank:] | cut -d " " -f5)
echo boot_tarball_size=$boot_tarball_size
sudo xz -9 -e /tmp/boot.tar
boot_sha256sum=$(sha256sum -z /tmp/boot.tar.xz | cut -d " " -f1)
cd ..
sudo umount /media/PI_BOOT/
sudo rm -rf /media/PI_BOOT/

echo starting root ...

sudo mkdir /media/PI_ROOT
sudo mount /dev/mapper/loop0p2 /media/PI_ROOT/
cd /media/PI_ROOT/
sudo bsdtar --numeric-owner --format gnutar --one-file-system -cpf /tmp/root.tar .
root_tarball_size=$(ls /tmp/root.tar -l --block-size=1MB |  tr -s [:blank:] | cut -d " " -f5)
echo root_tarball_size=$root_tarball_size
sudo xz -9 -e /tmp/root.tar
root_sha256sum=$(sha256sum -z /tmp/root.tar.xz | cut -d " " -f1)
cd ..
sudo umount /media/PI_ROOT/
sudo rm -rf /media/PI_ROOT/

cd $path
sleep 1

sudo kpartx -dv  2020-08-20-raspios-buster-arm64.img 

cat >os.json <<EOF
{
    "description": "A port of Debian with the Raspberry Pi Desktop",
    "feature_level": 35120124,
    "kernel": "5.4",
    "name": "Raspberry Pi OS (64-bit)",
    "password": "raspberry",
    "release_date": "2020-08-20",
    "supported_hex_revisions": "2082,20d3,3111,3112,3114",
    "supported_models": [
        "Pi 3",
        "Pi 3 Model B Rev",
        "Pi 4"
    ],
    "url": "http://www.raspbian.org/",
    "username": "pi",
    "version": "buster"
}
EOF

cat >partitions.json <<EOF
{
    "partitions": [
        {
            "filesystem_type": "FAT",
            "label": "boot",
            "mkfs_options": "-F 32",
            "partition_size_nominal": ${boot_size},
            "uncompressed_tarball_size": ${boot_tarball_size},
            "want_maximised": false,
            "sha256sum": "${boot_sha256sum}"
        },
        {
            "filesystem_type": "ext4",
            "label": "root",
            "mkfs_options": "-O ^huge_file",
            "partition_size_nominal": ${root_size},
            "uncompressed_tarball_size": ${root_tarball_size},
            "want_maximised": true,
            "sha256sum": "${root_sha256sum}"
        }
    ]
}
EOF
