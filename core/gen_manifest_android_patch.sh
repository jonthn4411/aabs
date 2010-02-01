#!/bin/bash
# $1: droid base branch, including remote and branch name
# $2: output_dir
# Assumes that android source code locates at <output_dir>/source

droid_base=$1
output_dir=$2
android_dir=$2/source
git rev-parse $droid_base >/dev/null 2>&1
if [ $? -eq 0 ]; then
	PWD=$(pwd | sed "s#$android_dir##" | sed "s#^/##") 
	REV=$(git merge-base HEAD $droid_base)
	echo \<project name=\"$REPO_PROJECT\" path=\"$PWD\" revision=\"$REV\" \/\>

	current_head=$(git rev-parse HEAD)
	if [ "$REV" != "$current_head" ]; then
		mkdir  -p  $output_dir/android_patches/$PWD
		git format-patch $REV..HEAD -o $output_dir/android_patches/$PWD >/dev/null
	fi
	rm -rf $android_dir/$PWD
else
	#TODO: we should check if what the base commit for the project is, only generate the patches from that base and
	#tar the source code as .mrvl_base_src.tgz and remove all the source code.

	#the output is expecting to be the manifest file so redirect it to /dev/null
	echo "TODO TAG2"
	tar czvf ../.mrvl_base_src.tgz * > /dev/null &&
	rm -fr * &&
	mv ../.mrvl_base_src.tgz .
fi

