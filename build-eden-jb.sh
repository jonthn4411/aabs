export ABS_BOARD=edenfpga
export ABS_DROID_BRANCH=jb
export ABS_SOC=eden
export ABS_DROID_VARIANT=userdebug
#export ABS_MANIFEST_BRANCH="$ABS_BOARD-$ABS_DROID_BRANCH"
export ABS_UNIQUE_MANIFEST_BRANCH=1

core/autobuild.sh $*
