#!/bin/bash
#assuming current working directory is output directory
#and the source code locates at "source"
#and the uboot and obm locates at source/boot/obm and source/boot/uboot
# $1: the uboot base commit
#
#After packaging the source and patches, the obm and uboot folder is deleted
output_dir=$(pwd)
boot_dir=$output_dir/source/boot
UBOOT_HASH=$1

EXCLUDE_VCS="--exclude-vcs --exclude=.repo"

if [ -z $UBOOT_HASH ]; then
	echo "Please specify the the base commit for UBOOT."
	exit 1
fi

cd $boot_dir/uboot &&
git rev-parse $UBOOT_HASH > /dev/null &&
rm -fr $output_dir/uboot_patches &&
mkdir -p $output_dir/uboot_patches &&
git format-patch $UBOOT_HASH..HEAD -o $output_dir/uboot_patches > /dev/null &&

echo "  packaging uboot base source code:" &&
git archive --format=tar --prefix=uboot/ $UBOOT_HASH  |gzip > ../uboot_src.tgz &&
cd .. &&
mv uboot_src.tgz $output_dir &&
rm -fr uboot &&
cd $output_dir &&
tar czf uboot_patches.tgz uboot_patches


