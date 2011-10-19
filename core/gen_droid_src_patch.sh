#!/bin/bash
#assuming current working directory is output directory
#and the source code locates at "source"
#
#After packaging the source and patches, the kernel folder is deleted

output_dir=$(pwd)
droid_base=$1
gen_manifest=$2
EXCLUDE_VCS="--exclude-vcs --exclude=.repo"
if [ -z $droid_base ] || [ -z $gen_manifest ]; then
	echo "Droid base commit or gen_manifest is empty."
	exit 1
fi

if [ ! -e $output_dir/prjlist ]; then
	echo "prjlist file can't be found."
	exit 2
fi

output_manifest=$output_dir/marvell_manifest.xml
echo "    generating android base manifest file and patches." &&
rm -fr $output_dir/android_patches &&
mkdir -p $output_dir/android_patches &&

cat > $output_manifest <<-EOF
<?xml version="1.0" encoding="UTF-8"?>
<manifest>
<remote fetch="https://android.googlesource.com/" name="aosp"/>
<default remote="aosp" revision=""/>

EOF

prjlist=$(cat prjlist)
for prj in $prjlist; do
	prjdir=${prj%%:*}
	export REPO_PROJECT=${prj##*:}
	if [ -d $prjdir ]; then
		cd $prjdir &&
		$gen_manifest/gen_manifest_android_patch.sh "$droid_base" "$output_dir" "$output_manifest"
	fi
done

echo '</manifest>' >>$output_manifest &&

cd $output_dir &&
tar czvf android_patches.tgz android_patches/ &&

echo "    tar the rest of android source code..." &&
tar czvf android_src.tgz $EXCLUDE_VCS source/


