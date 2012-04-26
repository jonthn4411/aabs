
BOOT_SRC_DIR:=boot

.PHONY:bootloader

define define-bootloader-target

bootloader_$(1): BOOT_OUT_DIR:=$$(BOOT_SRC_DIR)/out/$(1)
bootloader_$(1): BOOT_OUT_CM_DIR:=$$(BOOT_OUT_DIR)/CM
bootloader_$(1): BOOT_OUT_NOR_DIR:=$$(BOOT_OUT_DIR)/NORMAL
bootloader_$(1):
	$$(log) "[BOOTLOADER]Starting to build all bootloader images"
	$$(hide)cd $$(SRC_DIR) && \
		source ./build/envsetup.sh && \
		chooseproduct $(1) && choosetype $$(ABS_DROID_TYPE) && choosevariant $$(ABS_DROID_VARIANT) && \
		cd $$(SRC_DIR)/$$(BOOT_SRC_DIR) && make all
	$$(hide)mkdir -p $$(OUTPUT_DIR)/$(1)
	$$(hide)mkdir -p $$(OUTPUT_DIR)/$(1)/emmc
	$$(hide)mkdir -p $$(OUTPUT_DIR)/$(1)/emmc/ntim
	$$(hide)mkdir -p $$(OUTPUT_DIR)/$(1)/emmc_cm
	$$(hide)mkdir -p $$(OUTPUT_DIR)/$(1)/emmc_cm/ntim
	$$(log) "start to copy uboot and obm files"
	$$(hide)cp $$(SRC_DIR)/$$(BOOT_OUT_NOR_DIR)/u-boot.bin $$(OUTPUT_DIR)/$(1)/emmc
	$$(hide)cp $$(SRC_DIR)/$$(BOOT_OUT_NOR_DIR)/Wtm_rel_mmp3.bin $$(OUTPUT_DIR)/$(1)/emmc
	$$(hide)cp -rf $$(SRC_DIR)/$$(BOOT_OUT_NOR_DIR)/ntim/ $$(OUTPUT_DIR)/$(1)/emmc/
	$$(hide)cd $$(OUTPUT_DIR)/$(1)/emmc/ && tar zcvf ntim.bin.tgz ntim
	$$(hide)cp $$(SRC_DIR)/$$(BOOT_OUT_CM_DIR)/u-boot.bin $$(OUTPUT_DIR)/$(1)/emmc_cm
	$$(hide)cp $$(SRC_DIR)/$$(BOOT_OUT_CM_DIR)/Wtm_rel_mmp3.bin $$(OUTPUT_DIR)/$(1)/emmc_cm
	$$(hide)cp $$(SRC_DIR)/$$(BOOT_OUT_CM_DIR)/coremorphall.bin $$(OUTPUT_DIR)/$(1)/emmc_cm
	$$(hide)cp -rf $$(SRC_DIR)/$$(BOOT_OUT_CM_DIR)/ntim/ $$(OUTPUT_DIR)/$(1)/emmc_cm/
	$$(hide)cd $$(OUTPUT_DIR)/$(1)/emmc_cm/ && tar zcvf ntim.bin.tgz ntim
	$$(log) "[BOOTLOADER]Done:)"

PUBLISHING_FILES+=$(1)/emmc/u-boot.bin:m:md5
PUBLISHING_FILES+=$(1)/emmc/Wtm_rel_mmp3.bin:m:md5
PUBLISHING_FILES+=$(1)/emmc/ntim.bin.tgz:m:md5
PUBLISHING_FILES+=$(1)/emmc_cm/u-boot.bin:m:md5
PUBLISHING_FILES+=$(1)/emmc_cm/Wtm_rel_mmp3.bin:m:md5
PUBLISHING_FILES+=$(1)/emmc_cm/coremorphall.bin:m:md5
PUBLISHING_FILES+=$(1)/emmc_cm/ntim.bin.tgz:m:md5

bootloader: bootloader_$(1)

endef

.PHONY:clean_bootloader
clean_bootloader:
	$(log) "cleaning uboot and obm..."
	$(hide)cd $(SRC_DIR)/$(BOOT_SRC_DIR) && \
	make clean
	$(log) "    done."

$(foreach bv,$(ABS_BUILD_DEVICES), $(eval $(call define-bootloader-target,$(bv)) ) )

build_device: bootloader

