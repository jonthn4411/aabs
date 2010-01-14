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

	#workaround for keychars
	chmod 0644 /system/usr/keychars/*

	#workaround for android pm suspend 
	echo disable_pm_suspend > /sys/power/wake_lock

	EOF
}

echo "  modifying init.rc..." &&
sed -i "/^[ tab]*mount[ tab]*.\+[ tab]*\(\/system\|\/data\|\/cache\)/ s/mount/#(for nfs)mount/" init.rc &&
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
chmod 0755 init.nfs.sh &&

#don't mount sdcard in vold for NFS
echo "  disable mount sdcard in vold.conf"
sed -i '/^[ tab]*volume_sdcard/,/\}/ s/\(.*\)/#\1/' system/etc/vold.conf 

if [ $? -ne 0 ]; then
  exit 1
else
  exit 0
fi


