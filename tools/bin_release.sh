#!/bin/bash

# init version, Weichuan Yan, 2012-04-16

# usage:
# 1. setup android build env
# 2. ./bin_release.sh [<last release commit in source code>]
# notes: the tool will get the last release commit from binary release commit,
#        but if source code do force update or cherry-pick, the commit will change.
#        in this case, you should give the right last release commit hash to bin_release tool.


if [ -z "$ANDROID_BUILD_TOP" -o -z "$TARGET_PRODUCT" -o -z "$TARGET_BUILD_VARIANT" ]; then
	echo "Android build env not setup"
	exit
fi

# define the release binary and source dir and release dir here!!!
REL_FILE="libcr.so libcr_android.so"
REL_DIR=$ANDROID_BUILD_TOP/vendor/marvell/generic/libblcr
SOURCE_DIR=$ANDROID_BUILD_TOP/vendor/marvell/generic/libblcr_src

# check source code clean or not
cd $SOURCE_DIR
DIFF=$(git diff)
if [ -n "$DIFF" ]; then
	echo "Source code git is not clean, can't do release"
	exit
fi

# gen version
VER=$(date '+%y%m%d-%H%M%S')
echo "#ifndef ANDROID_BLCR_VERSION" > android/version.h
echo "#define ANDROID_BLCR_VERSION \"$VER\"" >> android/version.h
echo "#endif" >> android/version.h

# build new library with version info
source $ANDROID_BUILD_TOP/build/envsetup.sh
chooseproduct $TARGET_PRODUCT
choosevariant $TARGET_BUILD_VARIANT
mm -B

# copy new library to source code
mkdir -p $SOURCE_DIR/prebuilt
for file in $REL_FILE
do
	if [ -f $ANDROID_PRODUCT_OUT/system/lib/$file ]; then
		cp $ANDROID_PRODUCT_OUT/system/lib/$file $SOURCE_DIR/prebuilt
	else
		echo "Target file $ANDROID_PRODUCT_OUT/system/lib/$file not found!"
		exit
	fi
done

# get last release source code commit number
fixci=$1
if [ -z "$fixci" ]; then
	cd $REL_DIR
	LAST_CI=$(git show --pretty=oneline | awk -F: '{print $2}')
else
	LAST_CI=$fixci
fi
cd $SOURCE_DIR
git log  --oneline $LAST_CI..HEAD > /tmp/commit-body.txt
if [ "$?" != "0" ]; then
	echo "Get source change history failed, please check the last commit!"
	git reset --hard HEAD
	exit
fi

# commit the version info and new binary
git add prebuilt
git commit -s -m "Release $VER" prebuilt android/version.h
SRC_COMMIT=$(git rev-parse  HEAD)

#copy to release git, and do a commit
cd $REL_DIR
DIFF=$(git diff)
if [ -n "$DIFF" ]; then
	echo "Release git is not clean, can't do release"
	# revert source code commit
	cd $SOURCE_DIR
	git reset --hard HEAD^
	exit
fi
cp $SOURCE_DIR/prebuilt/* . -a
git add $REL_FILE
echo "Release $VER, source commit: $SRC_COMMIT" > /tmp/commit.txt
echo "" >> /tmp/commit.txt
echo "" >> /tmp/commit.txt
echo "Change log: " >> /tmp/commit.txt
echo "----------" >> /tmp/commit.txt
cat /tmp/commit-body.txt >> /tmp/commit.txt
git commit -s --file=/tmp/commit.txt $REL_FILE
