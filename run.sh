#!/bin/bash
# for debugging
set -xe

# create a temp directory
DATA="$(mktemp -d)"
MOUNT_DIR="$DATA/mnt"
DISK_IMG="$DATA/disk.img"

# create a disk image
dd if=/dev/zero of="$DISK_IMG" bs=1K count=128K

# create a loop device
LOOP="$(losetup -f "$DISK_IMG" --show)"

# create a filesystem on the loop device
mkfs -t ext4 "$LOOP"

# create a mount point
mkdir "$MOUNT_DIR"
mount "$LOOP" "$MOUNT_DIR"

# create a container
CID=$(docker run -d alpine apk add sysbench)
docker logs -f "$CID"
docker export "$CID" | tar -C "$MOUNT_DIR" -xf-
docker rm "$CID"

# run stage_b.sh in a new mount namespace
unshare --mount --net --pid --fork bash ./stage_b.sh "$MOUNT_DIR"