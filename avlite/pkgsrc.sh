#!/bin/bash
# $1: output_dir
# assuming the source code locates at <output_dir>/source

OUTPUT_DIR=$1

if [ ! -d "$OUTPUT_DIR" ]; then
  echo "output dir ($OUTPUT_DIR): doesn't exist"
  exit 1
fi

EXCLUDE_VCS="--exclude-vcs --exclude=.repo"

cd $OUTPUT_DIR/source &&
(
  echo "  packaging kernel source code:" &&
  tar czf kernel_src.tgz $EXCLUDE_VCS kernel/ &&
  mv kernel_src.tgz $OUTPUT_DIR &&
  rm -fr kernel &&

  echo "  packaging uboot and obm source code:" &&
  tar czf boot_src.tgz $EXCLUDE_VCS boot/ &&
  mv boot_src.tgz $OUTPUT_DIR &&
  rm -fr boot &&

  echo "  packaging gc300_driver source code: " &&
  cd vendor/marvell/generic/gc300 &&
  tar czf gc300_driver_src.tgz $EXCLUDE_VCS galcore_src/ &&
  mv gc300_driver_src.tgz $OUTPUT_DIR &&
  rm -fr gc300_driver 
) &&

echo "  packaging android source code:" &&
  if [ -d "$OUTPUT_DIR/source/vendor/marvell/generic/apps" ]; then
    rm -fr $OUTPUT_DIR/source/vendor/marvell/generic/apps
  fi &&
  if [ -d "$OUTPUT_DIR/source/vendor/marvell/external/helix" ]; then
    rm -fr $OUTPUT_DIR/source/vendor/marvell/external/helix
  fi &&
  if [ -d "$OUTPUT_DIR/source/vendor/marvell/external/flash" ]; then
    rm -fr $OUTPUT_DIR/source/vendor/marvell/external/flash
  fi &&
cd $OUTPUT_DIR &&
tar czf droid_src.tgz $EXCLUDE_VCS source/
