export ABS_SOC=pxa988fpga
export ABS_DROID_BRANCH=ics
export ABS_DROID_VARIANT=userdebug
export ABS_DROID_VFP=none
export PATH=/usr/lib/jvm/java-6-sun/bin/:$PATH
export ABS_BUILDHOST_DEF=buildhost.def

export ABS_UNIQUE_MANIFEST_BRANCH=1

core/autobuild.sh $*
