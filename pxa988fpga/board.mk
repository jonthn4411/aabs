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
include $(ABS_SOC)/pkg-source.mk

#
# Include goal for build android and kernels.
#
include $(ABS_SOC)/build-droid-kernel.mk

#define the combined goal to include all build goals
define define-build
build_$(1): build_droid_all_$(1)
endef
$(foreach bv, $(BUILD_VARIANTS), $(eval $(call define-build,$(bv) ) ) )

clean:clean_droid_kernel

#
# Include publish goal
#
include core/publish.mk


