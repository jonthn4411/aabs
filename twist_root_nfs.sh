#! /bin/bash
# modify the root_nfs folder for booting Android from NFS properly.
# The current folder running this script must be the folder of root nfs.
# This script can be run multiple times on the root nfs folder and still
# generate the proper result.

echo "  modifying init.rc..." &&
sed -in "/^[ tab]*mount yaffs2/ s/mount/#(for nfs)mount/" init.rc &&

sed -in "/^[ tab]*mount rootfs rootfs/ s/mount/#(for nfs)mount/" init.rc &&

sed -in '/^[ tab]*mkdir \/sdcard 0000 system system/ {
s/mkdir/#(for nfs)mkdir/ 
a\
    #>>>for nfs\
    mkdir \/sdcard 0777 root root\
    setprop EXTERNAL_STORAGE_STATE mounted\
    export amsd \"am broadcast -a android.intent.action.MEDIA_MOUNTED --ez read-only false -d file:\/\/\/sdcard\"\
    #<<<for nfs
}' init.rc &&

echo "  chmod a+r system/usr/keychars/*..." &&
chmod a+r ./system/usr/keychars/* 

if [ $? -ne 0 ]; then
  exit 1
else
  exit 0
fi


