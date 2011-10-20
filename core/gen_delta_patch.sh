#!/bin/sh

source_dir=$1
tools_dir=$2
last_ms=$3
last_chglog=$4
output_dir=`pwd`
output_source=$output_dir/source

if [ -z "$last_chglog" -o ! -f $last_ms ]; then
  exit
fi
if [ ! -f $last_chglog ]; then
  echo "last_chglog ($last_chglog) cannot be found at output_dir ($output_dir)."
  exit 1
fi
if [ ! -d $tools_dir -o ! -d $source_dir ]; then
  echo "Either tools_dir ($tools_dir) or source_dir ($source_dir) is wrong."
  exit 2
fi
if [ ! -d $output_source ]; then
  echo "The \'source\' dir cannot be found at output_dir ($output_dir)."
  exit 3
fi

rm -rf $output_dir/delta_patches
cd $source_dir
$tools_dir/extract_patches $output_dir/delta_patches $last_chglog -e aabs

new_prjs=`grep ":+newly added project, commits since" $last_chglog | awk -F: '{ print $2 }'`
for p in $new_prjs
do
  mkdir -p $output_dir/delta_patches/$p
  cp -pf $output_source/$p/* $output_dir/delta_patches/$p
done

purged_prjs=`grep ":-newly purged project." $last_chglog | awk -F: '{ print $1:$2 }'`
for p in $purged_prjs
do
  echo ${p#-} >> $output_dir/delta_patches/PURGED_PROJECTS
done
cp $last_ms $output_dir/delta_patches.base
tar czf $output_dir/delta_patches.tgz -C $output_dir/delta_patches .

