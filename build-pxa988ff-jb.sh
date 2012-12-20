export ABS_SOC=pxa988
export ABS_DROID_BRANCH=jb
export ABS_DROID_VARIANT=userdebug
export ABS_BOARD=pxa988ff
export PATH=/usr/lib/jvm/java-6-sun/bin/:$PATH
if [ -z "$ABS_BUILDHOST_DEF" ]; then
    ABS_BUILDHOST_DEF=buildhost4.def
fi
export ABS_BUILDHOST_DEF

core/autobuild.sh $*
