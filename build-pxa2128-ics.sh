# Used by AABS framework
export ABS_SOC=pxa2128
export ABS_DROID_BRANCH=ics
export ABS_BUILDHOST_DEF=buildhost.def

# Used only in droid.mk
export ABS_DROID_VARIANT=userdebug
export ABS_DROID_TYPE=release

export ABS_BUILD_DEVICES="abilene yellowstone"
core/autobuild.sh $*

