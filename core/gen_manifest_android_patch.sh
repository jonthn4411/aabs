#!/bin/bash
# $1: droid base branch, including remote and branch name
# $2: output_dir
# $3: output manifest file
# Assumes that android source code locates at <output_dir>/source

droid_base=$1
output_dir=$2
output_manifest=$3

android_dir=$2/source
git rev-parse $droid_base >/dev/null 2>&1
if [ $? -eq 0 ]; then
	curr_dir=$(pwd)
	repo_path=${curr_dir##$android_dir/}
	REV=$(git merge-base HEAD $droid_base)
	echo \<project name=\"$REPO_PROJECT\" path=\"$repo_path\" revision=\"$REV\" \/\> >> $output_manifest

	current_head=$(git rev-parse HEAD)
	if [ "$REV" != "$current_head" ]; then
		mkdir  -p  $output_dir/android_patches/$repo_path
		git format-patch $REV..HEAD -o $output_dir/android_patches/$repo_path >/dev/null
	fi
	rm -rf $android_dir/$repo_path
else
	#TODO: we should check if what the base commit for the project is, only generate the patches from that base and
	#tar the source code as .mrvl_base_src.tgz and remove all the source code.

	#the output is expecting to be the manifest file so redirect it to /dev/null
	if [ -d ".git" ]; then
		git archive --format=tar HEAD |gzip > ../mrvl_base_src.tgz 
	else
		tar czvf ../mrvl_base_src.tgz ./
	fi

	rm -fr * &&
	mv ../mrvl_base_src.tgz .
fi

