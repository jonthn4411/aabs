#!/bin/bash
# $1: output_dir

function remove_internal_apps()
{
  cd $OUTPUT_DIR/source/vendor/marvell/generic/apps
  subdirs=$(find -maxdepth 1 -type d)
  for dir in $subdirs
  do
    if [[ $dir == "." ]] || [[ $dir == ".." ]]; then
      continue
    fi
    rm -fr $dir
  done
  cd - >/dev/null
}

OUTPUT_DIR=$1

if [ ! -d "$OUTPUT_DIR" ]; then
  echo "output dir ($OUTPUT_DIR): doesn't exist"
  exit 1
fi
PKGSRC_EXCLUDE=./.git

cd $OUTPUT_DIR/source &&
echo "  packaging kernel source code:" &&
tar czf kernel_src.tgz --exclude=$PKGSRC_EXCLUDE kernel/ &&
mv kernel_src.tgz $OUTPUT_DIR &&
rm -fr kernel &&

echo "  packaging gc300_driver source code: " &&
tar czf gc300_driver_src.tgz --exclude=$PKGSRC_EXCLUDE gc300_driver/ &&
mv gc300_driver_src.tgz $OUTPUT_DIR &&
rm -fr gc300_driver &&

echo "  packaging uboot and obm source code:" &&
tar czf boot_src.tgz --exclude=$PKGSRC_EXECLUDE boot/ &&
mv boot_src.tgz $OUTPUT_DIR &&
rm -fr boot &&

echo "  packaging android source code:" &&
remove_internal_apps &&
cd $OUTPUT_DIR &&
tar czf droid_src.tgz --exclude=$PKGSRC_EXCLUDE source/
