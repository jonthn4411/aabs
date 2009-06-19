#! /bin/bash

sed -i "/^[ tab]*mount yaffs2 mtd@system/ s/mount yaffs2 mtd@system/mount ubifs ubi0_0/" init.rc && 
sed -i "/^[ tab]*mount yaffs2 mtd@userdata/ s/mount yaffs2 mtd@userdata/mount ubifs ubi1_0/" init.rc &&
sed -i "/^[ tab]*mount yaffs2 mtd@cache/ s/mount/#(for ubi)mount/" init.rc 
