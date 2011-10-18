#!/bin/bash

install_android_source()
{
	if [ ! -e $PKG_DROIDSRC ]; then
		echo "$PKG_DROIDSRC is not found."
		exit 1
	fi

	echo "  unpacking $PKG_DROIDSRC..."
	cd $(dirname $PKG_DROIDSRC) &&
	tar xzvf $PKG_DROIDSRC 
	check_result

	echo "   copying source/* to $android_working_dir ..."
	cp -f -p -r source/* $android_working_dir
	check_result

	echo "   unpack all mrvl_base_src.tgz..." &&
	cd $android_working_dir &&
	files=$(find . -type f -name mrvl_base_src.tgz ) &&
	for tarfile in $files; do
		echo "    uncompressing tarfile:$tarfile ..."
		cd $(dirname $tarfile) &&
		tar xzvf mrvl_base_src.tgz &&
		rm mrvl_base_src.tgz &&
		git init &&
		git add ./. -f &&
		git commit -s -m "init code from marvell"
		check_result
		cd -
	done
}

apply_android_patches()
{
	if [ ! -e $PKG_DROIDPATCH ]; then
		echo "$PKG_DROIDPATCH is not found."
		exit 1
	fi

	echo "  unpacking $PKG_DROIDPATCH..."
	cd $(dirname $PKG_DROIDPATCH) &&
	tar xzvf $PKG_DROIDPATCH 
	check_result

	echo "  applying patches ..." 
	cd android_patches &&
	patch_root_dir=$(pwd)
	android_patch_list=$(find . -type f -name "*.patch" | sort) &&
	for android_patch in $android_patch_list; do
		android_project=$(dirname $android_patch)
		echo "    applying patches on $android_project ..."
		cd $android_working_dir/$android_project 
		if [ $? -ne 0 ]; then
			echo "$android_project does not exist in android_working_dir:$android_working_dir"
			exit 1
		fi
		git am $patch_root_dir/$android_patch	
		check_result
	done
}

install_kernel_source()
{
	if [ ! -e $PKG_KERNELSRC ]; then
		echo "$PKG_KERNELSRC is not found."
		exit 1
	fi

	echo "  unpacking $PKG_KERNELSRC..."
	cd $(dirname $PKG_KERNELSRC) &&
	tar xzvf $PKG_KERNELSRC 
	check_result

	echo "   copying kernel/ to $android_working_dir/kernel ..." 
	mkdir -p $android_working_dir/kernel &&
	cp -p -r kernel $android_working_dir/kernel/ &&
	cd $android_working_dir/kernel/kernel &&
	git init &&
	git add ./. -f &&
	git commit -s -m "base code from marvell" 
	
	check_result
}

apply_kernel_patches()
{
	if [ ! -e $PKG_KERNELPATCH ]; then
		echo "$PKG_KERNELPATCH is not found."
		exit 1
	fi

	echo "  unpacking $PKG_KERNELPATCH..."
	cd $(dirname $PKG_KERNELPATCH) &&
	tar xzvf $PKG_KERNELPATCH 
	check_result

	echo "  applying kernel patches ..." 
	cd kernel_patches &&
	patch_root_dir=$(pwd) &&
	patch_list=$(find . -type f -name "*.patch" | sort) &&
	cd $android_working_dir/kernel/kernel &&
	for patch in $patch_list; do
		git am $patch_root_dir/$patch	
		check_result
	done
}

install_uboot_source()
{
	if [ ! -e $PKG_UBOOTSRC ]; then
		echo "!!!Warning:$PKG_UBOOTSRC is not found."
		return
	fi

	echo "  unpacking $PKG_UBOOTSRC..."
	cd $(dirname $PKG_UBOOTSRC) &&
	tar xzvf $PKG_UBOOTSRC 
	check_result

	echo "   copying uboot/ to $android_working_dir/boot/ ..." 
	mkdir -p $android_working_dir/boot &&
	cp -p -r uboot $android_working_dir/boot/ &&
	cd $android_working_dir/boot/uboot &&
	git init &&
	git add ./. -f &&
	git commit -s -m "base code from marvell" 
	
	check_result
}

apply_uboot_patches()
{
	if [ ! -e $PKG_UBOOTPATCH ]; then
		echo "!!!Warning:$PKG_UBOOTPATCH is not found."
		return	
	fi

	echo "  unpacking $PKG_UBOOTPATCH..."
	cd $(dirname $PKG_UBOOTPATCH) &&
	tar xzvf $PKG_UBOOTPATCH 
	check_result

	echo "  applying uboot patches ..." 
	cd uboot_patches &&
	patch_root_dir=$(pwd) &&
	patch_list=$(find . -type f -name "*.patch" | sort) &&
	cd $android_working_dir/boot/uboot &&
	for patch in $patch_list; do
		git am $patch_root_dir/$patch	
		check_result
	done
}

install_obm_source()
{
	if [ ! -e $PKG_OBMSRC ]; then
		echo "!!!Warning:$PKG_OBMSRC is not found."
		return
	fi

	echo "  unpacking $PKG_OBMSRC..."
	cd $(dirname $PKG_OBMSRC) &&
	tar xzvf $PKG_OBMSRC 
	check_result

	echo "   copying obm/ to $android_working_dir/boot/ ..." 
	mkdir -p $android_working_dir/boot &&
	cp -p -r obm $android_working_dir/boot/ &&
	cd $android_working_dir/boot/obm &&
	git init &&
	git add ./. -f &&
	git commit -s -m "base code from marvell" 
	
	check_result
}

apply_obm_patches()
{
	echo > /dev/null
}

install_toolchain()
{
	echo > /dev/null
}

install_rdroot()
{
	if [ -e $PKG_RDROOT ]; then
		mkdir -p $android_working_dir/kernel/rdroot
		cp $PKG_RDROOT $android_working_dir/kernel/rdroot
        fi
}

#####  Function to check result
check_result() {
if [ $? -ne 0 ]
then
	echo
	echo
	echo "FAIL: Install is aborted. Current working dir:$(pwd)"
	echo	
	exit 1
fi
}


######  Function to check whether an application exists
check_program() {
for cmd in "$@"
do
	which ${cmd} > /dev/null 2>&1
	if [ $? -ne 0 ]
	then
		echo
		echo "Cannot find command \"${cmd}\""
		echo
		exit 1
	fi
done
}


#####  Function to get user input of yes or no
get_yesno(){
export COMMAND=null
while [ ${COMMAND} = 'null' ]
do
	echo -n $@
	read COMMAND
	case "${COMMAND}" in
	yes);;
	no);;
	y)export COMMAND=yes;;
	n)export COMMAND=no;;
	*) 
		echo 'Invalid selection, please select "yes" or "no"'
		export COMMAND=null
		;;
	esac
done
}

function showRepoSetup()
{
echo 
echo 'Before the setup process can go on, you need first get a basic version of android.'
echo 'First, please visit source.android.com to install the repo tool and setup the android build environment'
echo 'Second, goto the android_working_dir you created and synced the basic code'
echo '	#repo init -u git://android.git.kernel.org/platform/manifest -b master'
echo 'Third, switch the code base to marvell code base,'
echo '	#cp marvell_manifest.xml .repo/manifests/'
echo '	#repo init -m marvell_manifest.xml'
echo '	#repo sync'
echo
}
###############################################
#            Main Process Begin               #
###############################################
PKG_ROOT=$(pwd)
PKG_DROIDSRC=$PKG_ROOT/android_src.tgz
PKG_DROIDPATCH=$PKG_ROOT/android_patches.tgz
PKG_KERNELSRC=$PKG_ROOT/kernel_src.tgz
PKG_KERNELPATCH=$PKG_ROOT/kernel_patches.tgz
PKG_UBOOTSRC=$PKG_ROOT/uboot_src.tgz
PKG_UBOOTPATCH=$PKG_ROOT/uboot_patches.tgz
PKG_OBMSRC=$PKG_ROOT/obm_src.tgz
PKG_OBMPATCH=$PKG_ROOT/obm_patches.tgz
PKG_TOOLCHAIN=$PKG_ROOT/toolchain.tgz
PKG_RDROOT=$PKG_ROOT/rdroot.tgz

# Note: Check necessary program for installation
echo -n "Checking necessary program for installation......"
check_program tar repo git
echo "Done"

if [ -z $1 ] || [ "$1" = "help" ]; then
	echo 
	echo 'Usage: ./setup_android.sh <android_working_dir>'
	echo '       <android_working_dir>:The directory that you will work on.'
	echo
	exit
fi

# Note: Test target directory
if [ -d $1 ]; then
	if [ ! -d $1/.repo ] || [ ! -e $1/.repo/manifests/marvell_manifest.xml ]; then
		showRepoSetup
		exit 1
	fi
	echo "Install marvell source and patches to the directory: $1"
else
	echo "Target directory not exists."
	showRepoSetup
	exit 1
fi

#convert the android_working_dir to absolute directory.
cd $1 &&
android_working_dir=$(pwd) &&
cd -

install_android_source 
apply_android_patches

install_kernel_source
apply_kernel_patches

install_uboot_source
apply_uboot_patches

install_obm_source
apply_obm_patches

install_toolchain

install_rdroot
echo 
echo "Success."
echo
