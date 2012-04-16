export ABS_BOARD=brownstone
export ABS_DROID_BRANCH=gingerbread
export ABS_SOC=mmp2
export ABS_DROID_VARIANT=user
export ABS_MANIFEST_BRANCH="$ABS_BOARD-$ABS_DROID_BRANCH"
export ABS_UNIQUE_MANIFEST_BRANCH=1

core/autobuild.sh $*
