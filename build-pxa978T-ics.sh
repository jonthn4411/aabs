export ABS_SOC=pxa978T
export ABS_DROID_BRANCH=ics
export ABS_DROID_VARIANT=userdebug
export PATH=/usr/lib/jvm/java-6-sun/bin/:$PATH
if [ -z "ABS_BUILDHOST_DEF" ]; then
    ABS_BUILDHOST_DEF=buildhost.def
fi
export ABS_BUILDHOST_DEF

export ABS_UNIQUE_MANIFEST_BRANCH=1

core/autobuild.sh $*
