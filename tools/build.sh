#!/bin/bash
#
#

get_date()
{
  echo $(date "+%Y-%m-%d %H:%M:%S")
}

print_usage()
{
	echo
	echo "Usage: build.sh [build_variant]"
	echo ""
	echo "    [build_variant]: user, userdebug or eng, the default value is userdebug"
}

build_variant=userdebug
if  [ $# -eq 1 ]; then
  build_variant=$1
elif [ $# -gt 1 ]; then
  print_usage
  exit 1
fi

echo "[$(get_date)]:set build enviroment..."
source build/envsetup.sh
chooseproduct brownstone
choosevariant $build_variant
export ANDROID_PREBUILT_MODULES=kernel/out/modules/

echo "[$(get_date)]:build kernel and modules..."
pushd ./kernel
make all
popd

echo "[$(get_date)]:build android..."
make -j4

echo "[$(get_date)]:build obm and uboot..."
pushd ./boot
make all
popd

echo "[$(get_date)]:build update packages..."
make droidupdate

echo "[$(get_date)]:build done."
