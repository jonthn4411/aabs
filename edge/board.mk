ifeq ($(strip $(BUILD_VARIANTS)),)
	BUILD_VARIANTS:=droid-gcc
endif

#
# Include goal for build android and kernels.
#
include $(BOARD)/build-droid-kernel.mk

#
# Include goal for build UBoot
#
UBOOT_CONFIG:=edge_config
UBOOT_SRC_DIR:=boot/uboot
include $(BOARD)/build-uboot.mk

#
# Include goal for build OBM
#
OBM_SRC_DIR:=boot/obm
include $(BOARD)/build-obm.mk

#define the combined goal to include all build goals
define define-build
build_$(1): build_droid_kernel_$(1) build_uboot_$(1) build_obm_$(1)
endef
$(foreach bv, $(BUILD_VARIANTS), $(eval $(call define-build,$(bv) ) ) )

clean:clean_droid_kernel clean_uboot clean_obm

