ANDROID_VERSION:=$(ABS_DROID_BRANCH)
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
include $(ABS_SOC)/build-droid-kernel.mk

#define the combined goal to include all build goals
.PHONY:build
define define-build
build: build_device_$(1)
endef

define define-build-device
tw:=$$(subst :,  , $(2))
product:=$$(word 1, $$(tw))
device:=$$(word 2, $$(tw))

build_device_$(1): build_device_$(1)_$$(product)
build_device_$(1)_$$(product): private_product:=$$(product)
build_device_$(1)_$$(product): private_device:=$$(device)
build_device_$(1)_$$(product): build_droid_kernel_$(1)_$$(product)
endef

$(foreach bv,$(BUILD_VARIANTS),\
	$(eval $(call define-build,$(bv)))\
	$(foreach bd,$(ABS_BUILD_DEVICES),\
		$(eval $(call define-build-device,$(bv),$(bd)))) \
)

.PHONY:clean
define define-clean
clean: clean_device_$(1)
endef

define define-clean-device
tw:=$$(subst :,  , $(2))
product:=$$(word 1, $$(tw))
device:=$$(word 2, $$(tw))

clean_device_$(1): clean_device_$(1)_$$(product)
clean_device_$(1)_$$(product): private_product:=$$(product)
clean_device_$(1)_$$(product): private_device:=$$(device)
clean_device_$(1)_$$(product): clean_droid_kernel_$(1)_$$(device)
endef

$(foreach bv,$(BUILD_VARIANTS),\
	$(eval $(call define-clean,$(bv)))\
	$(foreach bd,$(ABS_BUILD_DEVICES),\
		$(eval $(call define-clean-device,$(bv),$(bd))))\
)

#
# Include publish goal
#
include core/publish.mk

