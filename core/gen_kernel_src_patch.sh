#!/bin/bash
#assuming current working directory is output directory
#and the source code locates at "source"
#and the kernel locates at source/kernel/kernel
# $1: the kernel base commit
#
#After packaging the source and patches, the kernel folder is deleted

OUTPUT_DIR=$(pwd)
KERNEL_DIR=$OUTPUT_DIR/source/kernel/kernel
EXCLUDE_VCS="--exclude-vcs --exclude=.repo"
HASH=$1

if [ -z $HASH ]; then
	echo "Please specify the the base commit."
	exit 1
fi

cd $KERNEL_DIR &&
git rev-parse $HASH >/dev/null &&
rm -fr $OUTPUT_DIR/kernel_patches &&
mkdir -p $OUTPUT_DIR/kernel_patches &&
git format-patch $HASH..HEAD -o $OUTPUT_DIR/kernel_patches > /dev/null &&

echo "  packaging kernel base source code:" &&
git archive --format=tar --prefix=kernel/ $HASH |gzip > ../kernel_src.tgz &&
cd .. &&
rm -rf kernel 
mv kernel_src.tgz $OUTPUT_DIR &&

cd $OUTPUT_DIR &&
tar czf kernel_patches.tgz kernel_patches/
