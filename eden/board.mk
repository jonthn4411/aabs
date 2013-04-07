ABS_BUILD_DEVICES:=edenfpga_def:edenfpga

ANDROID_VERSION:=$(ABS_DROID_BRANCH)
DROID_VARIANT:=$(PLATFORM_ANDROID_VARIANT)

ifeq ($(strip $(DROID_VARIANT)),)
	DROID_VARIANT:=user
endif

#
# Include goal for build uboot, obm, android and kernels.
#
include $(ABS_SOC)/build-droid-kernel.mk

#define the combined goal to include all build goals
.PHONY:build

define define-build-device
tw:=$$(subst :,  , $(1))
product:=$$(word 1, $$(tw))
device:=$$(word 2, $$(tw))

build: build_device
build_device: build_device_$$(product)
build_device_$$(product): private_product:=$$(product)
build_device_$$(product): private_device:=$$(device)
build_device_$$(product): build_droid_kernel_$$(product)
endef

$(foreach bd,$(ABS_BUILD_DEVICES),\
	$(eval $(call define-build-device,$(bd))))

.PHONY:clean

define define-clean-device
tw:=$$(subst :,  , $(1))
product:=$$(word 1, $$(tw))
device:=$$(word 2, $$(tw))

clean: clean_device
clean_device: clean_device_$$(product)
clean_device_$$(product): private_product:=$$(product)
clean_device_$$(product): private_device:=$$(device)
clean_device_$$(product): clean_droid_kernel_$$(device)
endef

$(foreach bd,$(ABS_BUILD_DEVICES),\
	$(eval $(call define-clean-device,$(bd))))

