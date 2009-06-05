#! /bin/bash
# modify the root_nfs folder for booting Android from NFS properly.
# The current folder running this script must be the folder of root nfs.
# This script can be run multiple times on the root nfs folder and still
# generate the proper result.

function gen_init_nfs_sh()
{
	cat > $1 <<-EOF
	#!/system/bin/sh
	
	#simulate SD card and generate mounted intent
	chmod 0777 /sdcard
	chmod 0444 /sdcard/*.*
	setprop EXTERNAL_STORAGE_STATE mounted
	
	#touch the directory. A trick for NFS
	ls /sdcard >/dev/null	
	sleep 2s
	am broadcast -a android.intent.action.MEDIA_MOUNTED --ez read-only false -d file:///sdcard

	#work around for audio mixer, enable all the path by default
	#Enable Speaker
	amixer cset numid=8 3
	amixer cset numid=9 127
	amixer cset numid=10 1

	#Enable Headset
	amixer cset numid=6 127
	amixer cset numid=5 1

	#workaround for keychars
	chmod 0644 /system/usr/keychars/*

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

#add service to init nfs
if grep "service init-nfs /init.nfs.sh" init.rc >/dev/null; then
  echo "  already have service init-nfs defined..."
else
  cat >>init.rc <<-EOF
	
	#for nfs
	service init-nfs /init.nfs.sh
	    user root
	    group root
	    oneshot
	#for nfs
	
	EOF
fi &&

gen_init_nfs_sh init.nfs.sh &&
chmod 0755 init.nfs.sh 

if [ $? -ne 0 ]; then
  exit 1
else
  exit 0
fi


