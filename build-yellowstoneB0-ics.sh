# Used by AABS framework
export ABS_SOC=yellowstoneB0
export ABS_BUILDHOST_DEF=buildhost.def

export ABS_DROID_PRODUCT=yellowstone

# Used only in droid.mk
export ABS_DROID_VARIANT=userdebug
export ABS_DROID_TYPE=release

# Misc
# Are they redundant?
export ABS_DROID_BRANCH=ics
export ABS_PRODUCT_NAME=MMP3
export ABS_BOARD=yellowstoneB0


core/autobuild.sh $*

