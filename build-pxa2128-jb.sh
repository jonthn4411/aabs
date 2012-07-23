
# host env setting
export PATH=/usr/lib/jvm/java-6-sun/bin/:$PATH

# auto-build system setting
export ABS_SOC=pxa2128
export ABS_DROID_BRANCH=jb
export ABS_DROID_VARIANT=userdebug
export ABS_DROID_TYPE=release
export ABS_DROID_MAKE_JOBS=$(./tools/cpucount.sh)
export ABS_BUILDHOST_DEF=buildhost.def

# actual entry
core/autobuild.sh $*

