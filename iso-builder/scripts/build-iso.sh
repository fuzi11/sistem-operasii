#!/bin/bash
set -e
ISO=~/iso-builder/WebForgeOS
cd ~/iso-builder
rm -rf initramfs && mkdir -p initramfs/{bin,dev,proc,sys,newroot,mnt/{iso,ro,rw}}
cp /bin/busybox initramfs/bin/busybox
cp init.sh initramfs/init && chmod +x initramfs/init
mknod -m 600 initramfs/dev/console c 5 1
mknod -m 666 initramfs/dev/null c 1 3
cp /mnt/lfs/boot/vmlinuz-webforge-live $ISO/boot/vmlinuz
(cd initramfs && find . | cpio -o -H newc 2>/dev/null | gzip -9) > $ISO/boot/initrd.img
rm -f $ISO/live/filesystem.squashfs
mksquashfs /mnt/lfs $ISO/live/filesystem.squashfs -comp xz \
  -e proc sys dev run tmp mnt lost+found sources opt/alpine \
  etc/fstab etc/machine-id root/.bash_history var/log/journal
grub-mkrescue -o ~/iso-builder/WebForgeOS.iso $ISO
ls -lh ~/iso-builder/WebForgeOS.iso
