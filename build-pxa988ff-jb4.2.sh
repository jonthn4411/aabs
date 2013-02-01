export ABS_SOC=pxa988
export ABS_DROID_BRANCH=jb4.2
export ABS_DROID_VARIANT=userdebug
export ABS_BOARD=pxa988ff
export ABS_MANIFEST_BRANCH="rls_pxa988_jb4.2_wfdff"
#export ABS_MANIFEST_BRANCH="$ABS_BOARD-$ABS_DROID_BRANCH"
export PATH=/usr/lib/jvm/java-6-sun/bin/:$PATH
if [ -z "$ABS_BUILDHOST_DEF" ]; then
    ABS_BUILDHOST_DEF=buildhost4.def
fi
export ABS_BUILDHOST_DEF

export ABS_UNIQUE_MANIFEST_BRANCH=1

core/autobuild.sh $*
