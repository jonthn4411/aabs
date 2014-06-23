export ABS_SOC=pxa988
export ABS_DROID_BRANCH=kk4.4
export PATH=/usr/lib/jvm/java-6-sun/bin/:$PATH
if [ -z "ABS_BUILDHOST_DEF" ]; then
    ABS_BUILDHOST_DEF=buildhost.def
fi
export ABS_BUILDHOST_DEF

export ABS_UNIQUE_MANIFEST_BRANCH=1

export ABS_PUBLISH_DIR_BASE=/autobuild/android/pxa1U88
