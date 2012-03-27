include core/main.mk

#
# Include goal for repo source code
#
include core/repo-source.mk

#
# Include goal for generate changelog
#
include core/changelog.mk

#
# Include goal for package source code.
#
include $(ABS_SOC)/pkg-source.mk

#
# Include goal for build android and kernels.
#
include $(ABS_SOC)/build-droid-kernel-test.mk

# Include goal for build UBoot and OBM
include $(ABS_SOC)/build-uboot-obm-test.mk

# Include goal for build software downloader
include $(ABS_SOC)/build-swd.mk

# Include goal for build wtpsp
#include $(ABS_SOC)/build-wtpsp.mk

#define the combined goal to include all build goals
build: build_droid_kernel build_uboot_obm build_swd
build_uboot_obm: build_droid_kernel

clean:clean_droid_kernel clean_uboot_obm clean_swd clean_wtpsp

#
# Include publish goal
#
include core/publish.mk


