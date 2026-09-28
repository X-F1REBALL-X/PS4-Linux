#!/bin/bash
# Builds a 12GB raw USB image for PS4 Linux (run as root, e.g. inside WSL).
#   p1: 512MB FAT32 with bzImage + initramfs.cpio.gz
#   p2: ext4, label "psxitarch", with the Arch rootfs extracted
#
# Usage:
#   sudo bash build-img.sh <psxitarch.tar.xz> <bzImage> <initramfs.cpio.gz> <output.img>
# Example (WSL):
#   sudo bash build-img.sh /mnt/d/ps4/psxitarch.tar.xz boot/bzImage boot/initramfs.cpio.gz /mnt/d/ps4/psxitarch-usb.img
set -euo pipefail
[ $# -eq 4 ] || { echo "usage: $0 <psxitarch.tar.xz> <bzImage> <initramfs.cpio.gz> <output.img>"; exit 1; }
TAR=$1; BZ=$2; IRFS=$3; OUT=$4
for f in "$TAR" "$BZ" "$IRFS"; do [ -f "$f" ] || { echo "missing: $f"; exit 1; }; done
IMG=/root/psxitarch-usb.img   # build on the Linux filesystem (much faster than /mnt/c)
rm -f "$IMG"; truncate -s 12G "$IMG"
printf 'label: dos\nstart=2048, size=512MiB, type=c\ntype=83\n' | sfdisk "$IMG"
L=$(losetup -Pf --show "$IMG"); echo "loop=$L"; sleep 2
mkfs.vfat -F 32 "${L}p1"
mkfs.ext4 -F -L psxitarch "${L}p2"
mkdir -p /mnt/psx /mnt/psxboot
mount "${L}p2" /mnt/psx
echo "Extracting rootfs (takes a while)..."
tar -xJpf "$TAR" -C /mnt/psx --numeric-owner
for d in dev media mnt proc run sys tmp var/cache var/log var/tmp; do mkdir -p "/mnt/psx/$d"; done
chmod 1777 /mnt/psx/tmp /mnt/psx/var/tmp
mount "${L}p1" /mnt/psxboot
cp "$BZ" /mnt/psxboot/bzImage
cp "$IRFS" /mnt/psxboot/initramfs.cpio.gz
sync; ls -l /mnt/psxboot; df -h /mnt/psx
umount /mnt/psxboot /mnt/psx
e2fsck -fn "${L}p2" | tail -2
blkid "${L}p1" "${L}p2"
losetup -d "$L"
cp --sparse=never "$IMG" "$OUT" && rm -f "$IMG"
ls -l "$OUT"; sha256sum "$OUT"
echo BUILD_IMG_OK
