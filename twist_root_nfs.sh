#! /bin/bash
# modify the root_nfs folder for booting Android from NFS properly.
# The current folder running this script must be the folder of root nfs.
# This script can be run multiple times on the root nfs folder and still
# generate the proper result.

function gen_init_sdcard_sh()
{
	cat > $1 <<-EOF
	#!/system/bin/sh

	chmod 0777 /sdcard
	chmod 0444 /sdcard/*.*
	setprop EXTERNAL_STORAGE_STATE mounted
	
	#touch the directory. A trick for NFS
	ls /sdcard >/dev/null	
	sleep 2s
	am broadcast -a android.intent.action.MEDIA_MOUNTED --ez read-only false -d file:///sdcard
	EOF
}

echo "  modifying init.rc..." &&
sed -i "/^[ tab]*mount yaffs2/ s/mount/#(for nfs)mount/" init.rc &&

sed -i "/^[ tab]*mount rootfs rootfs/ s/mount/#(for nfs)mount/" init.rc &&

sed -i '/^[ tab]*mkdir \/sdcard 0000 system system/ {
s/mkdir/#(for nfs)mkdir/ 
a\
\
    #>>>for nfs\
    mkdir \/sdcard 0777 system system\
    chmod 0777 \/sdcard\
    export amsd \"am broadcast -a android.intent.action.MEDIA_MOUNTED --ez read-only false -d file:\/\/\/sdcard\"\
    #<<<for nfs\

}' init.rc &&

if grep "service init-sdcard /init.sdcard.sh" init.rc; then
  echo "  already have service init-sdcard define..."
else
  cat >>init.rc <<-EOF
	
	#for nfs
	service init-sdcard /init.sdcard.sh
	    user root
	    group root
	    oneshot
	#for nfs
	
	EOF
fi &&

gen_init_sdcard_sh init.sdcard.sh &&

chmod 0755 init.sdcard.sh &&

echo "  chmod a+r system/usr/keychars/*..." &&
chmod a+r ./system/usr/keychars/* 

if [ $? -ne 0 ]; then
  exit 1
else
  exit 0
fi


