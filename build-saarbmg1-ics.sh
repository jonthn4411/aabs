export ABS_BOARD=saarbmg1
export ABS_DROID_BRANCH=ics
export ABS_PRODUCT_NAME=saarbmg1
export PATH=/usr/lib/jvm/java-6-sun/bin/:$PATH
export ABS_BUILDHOST_DEF=buildhost.def
export ABS_DROID_VARIANT=userdebug
export ABS_UNIQUE_MANIFEST_BRANCH=1

core/autobuild.sh $*
