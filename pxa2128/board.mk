ABS_ALL_PRODUCTS := mk2
BOARD:=pxa2128
ANDROID_VERSION:=$(ABS_DROID_BRANCH)
PRODUCT_CODE:=$(BOARD)-$(ANDROID_VERSION)

include core/main.mk

include core/repo-source.mk

include core/changelog.mk

include $(ABS_SOC)/pkg-source.mk

#
# attention, the orders of the following 5 makefiles
#
include $(ABS_SOC)/product-target-define.mk

include $(ABS_SOC)/kernel.mk

include $(ABS_SOC)/droid.mk

#include $(ABS_SOC)/bootloader.mk

#include $(ABS_SOC)/droidupdate.mk

include core/publish.mk

