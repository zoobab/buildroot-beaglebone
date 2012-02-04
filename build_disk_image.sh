#!/bin/sh

set -e
export LC_ALL=C

if [ $# -ne 0 ]; then
	echo "Usage: $0"
	exit 1
fi

make beaglebone_erlang_defconfig
make

#OUTPUTFILE=bbone-erlang-`git describe`.img.gz
OUTPUTFILE=bbone-erlang-0.0.img

MBRFILE=/tmp/mbr.bin
VFATFILE=/tmp/vfat.bin

HEADS=255
SECTORS=63

VFAT_PART_CYLINDERS=1
ROOTFS_PART_CYLINDERS=16
USER_PART_CYLINDERS=124

dd if=/dev/zero of=$MBRFILE count=1
sfdisk -f -H $HEADS -S $SECTORS $MBRFILE << EOF
0,$VFAT_PART_CYLINDERS,c,*
,$ROOTFS_PART_CYLINDERS
,$USER_PART_CYLINDERS
EOF

# Keep mcopy from complaining
export MTOOLS_SKIP_CHECK=1

# Create a file for making the VFAT boot partition.
# It loses 1 block due to the MBR taking up the first block
dd if=/dev/zero of=$VFATFILE count=$(( $VFAT_PART_CYLINDERS * $HEADS * $SECTORS - 1 ))
mkfs.vfat $VFATFILE -n boot
mcopy -i $VFATFILE output/images/MLO ::
mcopy -i $VFATFILE output/images/uImage ::
mcopy -i $VFATFILE output/images/u-boot.img ::

# Mark that this is the first boot, so that the init scripts
# can format the user partition
touch /tmp/1stboot
mcopy -i $VFATFILE /tmp/1stboot ::

cat $MBRFILE $VFATFILE output/images/rootfs.ext2 > $OUTPUTFILE
zip ${OUTPUTFILE}.zip $OUTPUTFILE

# Clean up
rm $VFATFILE $MBRFILE /tmp/1stboot

echo "==================================================================="
echo "Created $OUTPUTFILE and $OUTPUTFILE.zip."
echo
echo "Write to a MicroSD card by running:"
echo
echo "sudo dd if=$OUTPUTFILE of=/dev/sdX bs=128k"
echo "where sdX is where the MicroSD card was mounted."

