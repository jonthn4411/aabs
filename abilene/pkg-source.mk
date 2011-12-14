INTERNAL_PROJECTS +=boot/obm/.git
INTERNAL_PROJECTS +=kernel/mrvl-tool-chain
#INTERNAL_PROJECTS +=boot/obm/binaries/Wtm_rel_mmp2.bin

KERNEL_BASE_COMMIT:=$(KERNEL_2_6_32_BASE_COMMIT)
UBOOT_BASE_COMMIT:=$(UBOOT_2009RC1_BASE_COMMIT)

ifeq ($(ANDROID_VERSION),gingerbread)
	KERNEL_BASE_COMMIT:=$(KERNEL_2_6_35_BASE_COMMIT)
	UBOOT_BASE_COMMIT:=$(UBOOT_201009_BASE_COMMIT)
else
ifeq ($(ANDROID_VERSION),ics)
       KERNEL_BASE_COMMIT:=$(KERNEL_3_0_BASE_COMMIT)
       UBOOT_BASE_COMMIT:=b20a91d81fbdf9402df5425126bdee3368f10044
else
ifeq ($(ANDROID_VERSION),honeycomb)
	KERNEL_BASE_COMMIT:=9abd59b0df155835a970c2b9c8f93367eb793797
	UBOOT_BASE_COMMIT:=e1b4c57096b87b4ada56df4154d9acee6a59141f
endif
endif
endif

#format: <file name>:[m|o]:[md5]
#m:means mandatory
#o:means optional
#md5: need to generate md5 sum

#
# Sample from brownstone
#
#PUBLISHING_FILES+=$(ANDROID_VERSION)_RN.pdf:o
#
#publish_RN:
#	$(hide)cp $(BOARD)/$(ANDROID_VERSION)_RN.pdf $(OUTPUT_DIR)
#
#pkgsrc: publish_RN
#
