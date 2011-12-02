export ABS_BOARD=brownstone
export ABS_DROID_BRANCH=ics
export ABS_PRODUCT_NAME=MMP2
export ABS_DROID_VARIANT=userdebug
export ABS_MANIFEST_BRANCH="$ABS_BOARD-$ABS_DROID_BRANCH"
export ABS_UNIQUE_MANIFEST_BRANCH=1

core/autobuild.sh $*
