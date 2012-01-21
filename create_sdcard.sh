#!/bin/sh -e

export LC_ALL=C

if [ $# -ne 1 ]; then
	echo "Usage: sudo $0 </dev/sdX>"
	exit 1
fi

DRIVE=$1

sfdisk -H 255 -S 63 $DRIVE << EOF
0,9,c,*
,62
,62
,124
EOF

mkfs.vfat ${DRIVE}1 -n boot
mkdir -p /tmp/sdcard
mount ${DRIVE}1 /tmp/sdcard
cp output/images/MLO /tmp/sdcard
cp output/images/uImage /tmp/sdcard
cp output/images/u-boot.img /tmp/sdcard
umount /tmp/sdcard
rmdir /tmp/sdcard

dd if=output/images/rootfs.ext2 of=${DRIVE}2 bs=128k

mkfs.ext2 -L home ${DRIVE}4
