export ABS_BOARD=yellowstone
export ABS_DROID_BRANCH=ics
export ABS_PRODUCT_NAME=MMP3
export ABS_BUILDHOST_DEF=buildhost.def
export ABS_DROID_VARIANT=userdebug
export PATH=/usr/lib/jvm/java-6-sun/bin/:$PATH

core/autobuild.sh $*
