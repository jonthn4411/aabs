BOARD:=$(ABS_BOARD)
ANDROID_VERSION:=$(ABS_DROID_BRANCH)
PRODUCT_CODE:=$(ABS_BOARD)-$(ANDROID_VERSION)
MANIFEST_FILE:=$(ABS_DROID_MANIFEST)
DROID_VARIANT:=$(ABS_DROID_VARIANT)

ifeq ($(strip $(DROID_VARIANT)),)
	DROID_VARIANT:=user
endif

ifeq ($(strip $(BUILD_VARIANTS)),)
	BUILD_VARIANTS:=droid-gcc
endif

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
include common/pkg-source.mk

#
# Include goal for build uboot, obm, android and kernels.
#
include $(BOARD)/build-droid-kernel.mk

#define the combined goal to include all build goals
define define-build
build_$(1): build_droid_kernel_$(1)
endef
$(foreach bv, $(BUILD_VARIANTS), $(eval $(call define-build,$(bv) ) ) )

clean:clean_droid_kernel clean_uboot

#
# Include publish goal
#
include core/publish.mk

