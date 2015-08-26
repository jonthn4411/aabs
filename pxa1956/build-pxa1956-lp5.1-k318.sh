export ABS_SOC=pxa1956
export ABS_DROID_BRANCH=lp5.1
export PATH=/usr/lib/jvm/java-6-sun/bin/:$PATH
if [ -z "ABS_BUILDHOST_DEF" ]; then
    ABS_BUILDHOST_DEF=buildhost.def
fi
export ABS_BUILDHOST_DEF

export ABS_UNIQUE_MANIFEST_BRANCH=1

export ABS_BUILD_DEVICES="pxa1956dkb_tz:pxa1956dkb"
export ABS_MANIFEST_BRANCH='rls_pxa1956-lp5.1_k318'