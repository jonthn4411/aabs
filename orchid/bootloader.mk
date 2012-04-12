
BOOT_SRC_DIR:=boot
BOOT_OUT_DIR:=$(BOOT_SRC_DIR)/out
BOOT_OUT_CM_DIR:=$(BOOT_OUT_DIR)/CM
BOOT_OUT_NOR_DIR:=$(BOOT_OUT_DIR)/NORMAL

PUBLISHING_FILES+=prebuilt/emmc/u-boot.bin:m:md5
PUBLISHING_FILES+=prebuilt/emmc/Wtm_rel_mmp3.bin:m:md5 PUBLISHING_FILES+=prebuilt/emmc/ntim.bin.tgz:m:md5
PUBLISHING_FILES+=prebuilt/emmc_cm/u-boot.bin:m:md5
PUBLISHING_FILES+=prebuilt/emmc_cm/Wtm_rel_mmp3.bin:m:md5
PUBLISHING_FILES+=prebuilt/emmc_cm/coremorphall.bin:m:md5
PUBLISHING_FILES+=prebuilt/emmc_cm/ntim.bin.tgz:m:md5

.PHONY:bootloader
bootloader:
	$(log) "[BOOTLOADER]Starting to build all bootloader images"
	$(hide)cd $(SRC_DIR) && \
		source ./build/envsetup.sh && \
		chooseproduct $(ABS_DROID_PRODUCT) && choosetype $(ABS_DROID_TYPE) && choosevariant $(ABS_DROID_VARIANT) && \
		cd $(SRC_DIR)/$(BOOT_SRC_DIR) && make all
	$(hide)mkdir -p $(OUTPUT_DIR)/prebuilt
	$(hide)mkdir -p $(OUTPUT_DIR)/prebuilt/emmc
	$(hide)mkdir -p $(OUTPUT_DIR)/prebuilt/emmc/ntim
	$(hide)mkdir -p $(OUTPUT_DIR)/prebuilt/emmc_cm
	$(hide)mkdir -p $(OUTPUT_DIR)/prebuilt/emmc_cm/ntim

	$(log) "start to copy uboot and obm files"
	$(hide)cp $(SRC_DIR)/$(BOOT_OUT_NOR_DIR)/u-boot.bin $(OUTPUT_DIR)/prebuilt/emmc
	$(hide)cp $(SRC_DIR)/$(BOOT_OUT_NOR_DIR)/Wtm_rel_mmp3.bin $(OUTPUT_DIR)/prebuilt/emmc
	$(hide)cp -rf $(SRC_DIR)/$(BOOT_OUT_NOR_DIR)/ntim/ $(OUTPUT_DIR)/prebuilt/emmc/
	$(hide)cd $(OUTPUT_DIR)/prebuilt/emmc/ && tar zcvf ntim.bin.tgz ntim
	$(hide)cp $(SRC_DIR)/$(BOOT_OUT_CM_DIR)/u-boot.bin $(OUTPUT_DIR)/prebuilt/emmc_cm
	$(hide)cp $(SRC_DIR)/$(BOOT_OUT_CM_DIR)/Wtm_rel_mmp3.bin $(OUTPUT_DIR)/prebuilt/emmc_cm
	$(hide)cp $(SRC_DIR)/$(BOOT_OUT_CM_DIR)/coremorphall.bin $(OUTPUT_DIR)/prebuilt/emmc_cm
	$(hide)cp -rf $(SRC_DIR)/$(BOOT_OUT_CM_DIR)/ntim/ $(OUTPUT_DIR)/prebuilt/emmc_cm/
	$(hide)cd $(OUTPUT_DIR)/prebuilt/emmc_cm/ && tar zcvf ntim.bin.tgz ntim
	$(log) "[BOOTLOADER]Done:)"

.PHONY:clean_bootloader
clean_bootloader:
	$(log) "cleaning uboot and obm..."
	$(hide)cd $(SRC_DIR)/$(BOOT_SRC_DIR) && \
	make clean
	$(log) "    done."

build_device: bootloader

