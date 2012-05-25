export ABS_BOARD=pxa988fpga
export ABS_DROID_BRANCH=ics
export ABS_PRODUCT_NAME=pxa988fpga
export PATH=/usr/lib/jvm/java-6-sun/bin/:$PATH
export ABS_BUILDHOST_DEF=buildhost.def
export ABS_DROID_VARIANT=userdebug
export ABS_DROID_VFP=none
export ABS_MANIFEST_BRANCH="$ABS_BOARD-$ABS_DROID_BRANCH"
export ABS_UNIQUE_MANIFEST_BRANCH=1

core/autobuild.sh $*
