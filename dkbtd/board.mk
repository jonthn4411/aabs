ifeq ($(strip $(BUILD_VARIANTS)),)
	BUILD_VARIANTS:=droid-gcc
endif

include core/main.mk

#
# Include goal for repo source code
#
GIT_LOCAL_MIRROR:=/home/jingjing/mirrors/default
include core/repo-source.mk

#
# Include goal for generate changelog
#
include core/changelog.mk

#
# Include goal for package source code.
#
include $(BOARD)/pkg-source.mk

#
# Include goal for build android and kernels.
#
include $(BOARD)/build-droid-kernel.mk

#
# Include goal for build UBoot and OBM
#
include $(BOARD)/build-uboot-obm.mk

#
# Copy obm and CP images
#
include $(BOARD)/copy-obm-cp-image.mk

#define the combined goal to include all build goals
define define-build
build_$(1): build_uboot_obm_$(1) build_droid_all_$(1) copy_obm_cp_image_$(1)
endef
$(foreach bv, $(BUILD_VARIANTS), $(eval $(call define-build,$(bv) ) ) )

clean:clean_droid_kernel clean_uboot_obm

#
# Include publish goal
#
include core/publish.mk


