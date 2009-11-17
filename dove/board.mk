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
include avlite/pkg-source.mk

#
# Include goal for build android and kernels.
#
include avlite/build-droid-kernel.mk

#
# Include goal for build UBoot
#
UBOOT_CONFIG:=avengers_config
UBOOT_SRC_DIR:=boot/uboot
include avlite/build-uboot.mk

#
# Include goal for build OBM
#
OBM_SRC_DIR:=boot/obm
include avlite/build-obm.mk

#define the combined goal to include all build goals
define define-build
build_$(1): build_droid_kernel_$(1) build_uboot_$(1) build_obm_$(1)
endef
$(foreach bv, $(BUILD_VARIANTS), $(eval $(call define-build,$(bv) ) ) )

clean:clean_droid_kernel clean_uboot clean_obm

#
# Include publish goal
#
include core/publish.mk


