ABS_BUILD_DEVICES?=pxa1928dkb_tz:pxa1928dkb:pxa1928dkb_dsds

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

build: build_device

.PHONY:build_device
define define-build-device
tw:=$$(subst :,  , $(1))
product:=$$(word 1, $$(tw))
device:=$$(word 2, $$(tw))
#$$(warning define-build-device arg1=$(1) tw=$$(tw) product=$$(product) device=$$(device))
build_device_$$(product): private_product:=$$(product)
build_device_$$(product): private_device:=$$(device)
build_device_$$(product): build_droid_kernel_$$(product)
build_device: build_device_$$(product)
endef

$(foreach bd1, $(ABS_BUILD_DEVICES), $(eval $(call define-build-device,$(bd1))))

.PHONY:clean

clean: clean_device

define define-clean-device
tw:=$$(subst :,  , $(1) )
product:=$$(word 1, $$(tw) )
device:=$$(word 2, $$(tw) )
#$$(warning define-clean-device arg1=$(1) tw=$$(tw) product=$$(product) device=$$(device))
clean_device_$$(product): private_product:=$$(product)
clean_device_$$(product): private_device:=$$(device)
clean_device_$$(product): clean_droid_kernel_$$(product)
clean_device: clean_device_$$(device)
endef

$(foreach bd, $(ABS_BUILD_DEVICES), $(eval $(call define-clean-device,$(bd))))

