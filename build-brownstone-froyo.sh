export ABS_BOARD=brownstone
export ABS_DROID_BRANCH=froyo
export ABS_PRODUCT_NAME=MMP2
export ABS_DROID_VARIANT=user
export ABS_MANIFEST_BRANCH="$ABS_BOARD-$ABS_DROID_BRANCH"

core/autobuild.sh $*
