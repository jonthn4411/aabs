# Used by AABS framework
export ABS_SOC=mk2
export ABS_BUILDHOST_DEF=buildhost.def

# Used only in droid.mk
export ABS_DROID_PRODUCT=mk2
export ABS_DROID_VARIANT=userdebug
export ABS_DROID_TYPE=release

# Misc
# Are they redundant?
export ABS_DROID_BRANCH=jellybean
export ABS_PRODUCT_NAME=MMP3
export ABS_BOARD=mk2


core/autobuild.sh $*

