# (fixme)jason
# Remove these two variables
# They are used in orchid/pkg-source.mk
BOARD:=mk2
ANDROID_VERSION:=jellybean

.PHONY:build clean

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

###### Begin a real build of Kernel, Android, Bootloader ######

# Attach your own target to 'build_device'.
# Do not attach any android, kernel or bootloader targets to 'build' directly.
.PHONY: build_device
build: build_device

include $(ABS_SOC)/kernel.mk

include $(ABS_SOC)/droid.mk

include $(ABS_SOC)/bootloader.mk

#include $(ABS_SOC)/droidupdate.mk

###### End a real build of Kernel, Android, Bootloader ######

#
# Include publish goal
#
include core/publish.mk

