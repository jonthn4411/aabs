export ABS_SOC=pxa1936
export ABS_DROID_BRANCH=lp5.0
if [ -z "ABS_BUILDHOST_DEF" ]; then
     ABS_BUILDHOST_DEF=buildhost.def
fi
export ABS_BUILDHOST_DEF
 
export ABS_UNIQUE_MANIFEST_BRANCH=1
export ABS_PUBLISH_DIR_BASE=/autobuild/android/pxa1908
export ABS_BUILD_DEVICES="pxa1908FF_tz:pxa1908FF pxa1908dkb_tz:pxa1908dkb pxa1908dkb_64bit:pxa1908dkb"

