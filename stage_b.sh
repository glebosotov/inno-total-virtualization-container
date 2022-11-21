#!/bin/bash

# for debugging
set -xe

MOUNT_DIR="$1"

mkdir "$MOUNT_DIR/oldroot"
pivot_root "$MOUNT_DIR" "$MOUNT_DIR/oldroot"

mount -t proc proc /proc

umount -l /oldroot
rmdir /oldroot

cd /
exec chroot / sh