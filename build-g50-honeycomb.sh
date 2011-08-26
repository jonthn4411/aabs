export ABS_BOARD=g50
export ABS_DROID_BRANCH=honeycomb
export ABS_PRODUCT_NAME=MMP2
export ABS_BUILDHOST_DEF=buildhost2.def
export ABS_DROID_VARIANT=userdebug
export ABS_MANIFEST_BRANCH="$ABS_BOARD-$ABS_DROID_BRANCH"

core/autobuild.sh $*
