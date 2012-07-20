ABS_BUILD_DEVICES := pxa978dkb_def:pxa978dkb pxa978ariel_def:pxa978ariel pxa978ariel_cmcc:pxa978ariel_cmcc

#Add on patches for special products, will call apply-patch.sh in the folder to apply those patches
#product:relative path in SRC_DIR
CMCC_OT_PATCHES:=vendor/marvell/carrier/cmcc_ot_patches
ABS_PRODUCT_ADDON_PATCH := pxa978dkb_def: pxa978ariel_def: pxa978ariel_cmcc:$(CMCC_OT_PATCHES)

BOARD:=pxa978T
ANDROID_VERSION:=$(ABS_DROID_BRANCH)
PRODUCT_CODE:=$(BOARD)-$(ANDROID_VERSION)

ifeq ($(ABS_DROID_BRANCH),jb)
ABS_BUILD_DEVICES := pxa978dkb_def:pxa978dkb
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
include $(ABS_SOC)/pkg-source.mk

#
# Include goal for build android and kernels.
#
include $(ABS_SOC)/build-droid-kernel.mk
#include $(ABS_SOC)/build-droid-kernel-test.mk

# Include goal for build UBoot and OBM
include $(ABS_SOC)/build-uboot-obm.mk

# Include goal for build software downloader
include $(ABS_SOC)/build-swd.mk

# Include goal for build wtpsp
#include $(ABS_SOC)/build-wtpsp.mk

#define the combined goal to include all build goals
build: build_device
build: build_swd

.PHONY:build_device
define define-build-device
tw:=$$(subst :,  , $(1) )
product:=$$(word 1, $$(tw) )
device:=$$(word 2, $$(tw) )

build_device_$$(product): private_product:=$$(product)
build_device_$$(product): private_device:=$$(device)
build_device_$$(product): build_droid_kernel_$$(product) build_uboot_obm_$$(product)
build_device: build_device_$$(product)
endef

$(foreach bv1, $(ABS_BUILD_DEVICES), $(eval $(call define-build-device,$(bv1) ) ))

.PHONY:clean
clean:clean_device clean_swd clean_wtpsp

define define-clean-device
tw:=$$(subst :,  , $(1) )
product:=$$(word 1, $$(tw) )
device:=$$(word 2, $$(tw) )
clean_device_$$(product): private_product:=$$(product)
clean_device_$$(product): private_device:=$$(device)
clean_device_$$(product): clean_droid_kernel_$$(product) clean_uboot_obm_$$(product)
clean_device:clean_device_$$(product)
endef
$(foreach bv, $(ABS_BUILD_DEVICES), $(eval $(call define-clean-device,$(bv) ) ) )

#
# Include publish goal
#
include core/publish.mk


