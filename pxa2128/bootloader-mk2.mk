
BOOT_SRC_DIR:=boot
BOOT_OUT_DIR:=$(BOOT_SRC_DIR)/out

PUBLISHING_FILES+=mk2/emmc/tim_mk2-1063-1063-532-532-399-399-399-200__4_1_sm_400_1275mv_primary_b0p.bin:m:md5
PUBLISHING_FILES+=mk2/emmc/tim_mk2-1063-1063-532-532-399-399-399-200__4_1_sm_400_1275mv_backup_b0p.bin:m:md5
PUBLISHING_FILES+=mk2/emmc/tim_mk2-1196-1196-598-598-399-399-399-200__1p2g_1_sm_400_1275mv_primary_b0p.bin:m:md5
PUBLISHING_FILES+=mk2/emmc/tim_mk2-1196-1196-598-598-399-399-399-200__1p2g_1_sm_400_1275mv_backup_b0p.bin:m:md5
PUBLISHING_FILES+=mk2/emmc/Wtm_rel_mmp3.bin:m:md5
PUBLISHING_FILES+=mk2/emmc/Wtm_rel_mmp3_backup.bin:m:md5
PUBLISHING_FILES+=mk2/emmc/MMP3_LINUX_ARM_TZ.bin:m:md5
PUBLISHING_FILES+=mk2/emmc/MMP3_LINUX_ARM_TZ_backup.bin:m:md5
PUBLISHING_FILES+=mk2/emmc/tzl.bin:m:md5
PUBLISHING_FILES+=mk2/emmc/tzl_backup.bin:m:md5
PUBLISHING_FILES+=mk2/emmc/dtim_platform_primary.bin:m:md5
PUBLISHING_FILES+=mk2/emmc/dtim_platform_recovery.bin:m:md5
PUBLISHING_FILES+=mk2/emmc/u-boot.bin:m:md5
PUBLISHING_FILES+=mk2/emmc/u-boot_recovery.bin:m:md5

PUBLISHING_FILES+=mk2/emmc/EB_JO/tim_mk2-1063-1063-532-532-399-399-399-200__4_1_sm_400_1275mv_backup_b0p.bin:m:md5
PUBLISHING_FILES+=mk2/emmc/EB_JO/tim_mk2-1063-1063-532-532-399-399-399-200__4_1_sm_400_1275mv_primary_b0p.bin:m:md5
PUBLISHING_FILES+=mk2/emmc/EB_JO/tim_mk2-1196-1196-598-598-399-399-399-200__1p2g_1_sm_400_1275mv_backup_b0p.bin:m:md5
PUBLISHING_FILES+=mk2/emmc/EB_JO/tim_mk2-1196-1196-598-598-399-399-399-200__1p2g_1_sm_400_1275mv_primary_b0p.bin:m:md5
PUBLISHING_FILES+=mk2/emmc/EB_JO/Wtm_rel_mmp3_backup.bin:m:md5
PUBLISHING_FILES+=mk2/emmc/EB_JO/Wtm_rel_mmp3.bin:m:md5
PUBLISHING_FILES+=mk2/emmc/EB_JO/MMP3_LINUX_ARM_TZ_backup.bin:m:md5
PUBLISHING_FILES+=mk2/emmc/EB_JO/MMP3_LINUX_ARM_TZ.bin:m:md5

PUBLISHING_FILES+=mk2/emmc/PB_JO/tim_mk2-1063-1063-532-532-399-399-399-200__4_1_sm_400_1275mv_backup_b0p.bin:m:md5
PUBLISHING_FILES+=mk2/emmc/PB_JO/tim_mk2-1063-1063-532-532-399-399-399-200__4_1_sm_400_1275mv_primary_b0p.bin:m:md5
PUBLISHING_FILES+=mk2/emmc/PB_JO/tim_mk2-1196-1196-598-598-399-399-399-200__1p2g_1_sm_400_1275mv_backup_b0p.bin:m:md5
PUBLISHING_FILES+=mk2/emmc/PB_JO/tim_mk2-1196-1196-598-598-399-399-399-200__1p2g_1_sm_400_1275mv_primary_b0p.bin:m:md5
PUBLISHING_FILES+=mk2/emmc/PB_JO/Wtm_rel_mmp3_backup.bin:m:md5
PUBLISHING_FILES+=mk2/emmc/PB_JO/Wtm_rel_mmp3.bin:m:md5
PUBLISHING_FILES+=mk2/emmc/PB_JO/MMP3_LINUX_ARM_TZ_backup.bin:m:md5
PUBLISHING_FILES+=mk2/emmc/PB_JO/MMP3_LINUX_ARM_TZ.bin:m:md5

PUBLISHING_FILES+=mk2/emmc/PB/tim_mk2-1063-1063-532-532-399-399-399-200__4_1_sm_400_1275mv_backup_b0p.bin:m:md5
PUBLISHING_FILES+=mk2/emmc/PB/tim_mk2-1063-1063-532-532-399-399-399-200__4_1_sm_400_1275mv_primary_b0p.bin:m:md5
PUBLISHING_FILES+=mk2/emmc/PB/tim_mk2-1196-1196-598-598-399-399-399-200__1p2g_1_sm_400_1275mv_backup_b0p.bin:m:md5
PUBLISHING_FILES+=mk2/emmc/PB/tim_mk2-1196-1196-598-598-399-399-399-200__1p2g_1_sm_400_1275mv_primary_b0p.bin:m:md5
PUBLISHING_FILES+=mk2/emmc/PB/Wtm_rel_mmp3_backup.bin:m:md5
PUBLISHING_FILES+=mk2/emmc/PB/Wtm_rel_mmp3.bin:m:md5
PUBLISHING_FILES+=mk2/emmc/PB/MMP3_LINUX_ARM_TZ_backup.bin:m:md5
PUBLISHING_FILES+=mk2/emmc/PB/MMP3_LINUX_ARM_TZ.bin:m:md5

PUBLISHING_FILES+=mk2/emmc/print_MMP3_FuseVal.xdb:m:md5
PUBLISHING_FILES+=mk2/emmc/PRE_SetupClocks.xdb:m:md5

build_product_bootloader_mk2:
	$(log) "[BOOTLOADER-mk2]Starting to build all bootloader images"
	$(hide)cd $(SRC_DIR) && \
		source ./build/envsetup.sh && \
		chooseproduct mk2 && choosetype $(ABS_DROID_TYPE) && choosevariant $(ABS_DROID_VARIANT) && \
		cd $(SRC_DIR)/$(BOOT_SRC_DIR) && make all
	$(hide)mkdir -p $(OUTPUT_DIR)/mk2
	$(hide)mkdir -p $(OUTPUT_DIR)/mk2/emmc

	$(log) "start to copy uboot and obm files"
	$(hide)cp $(SRC_DIR)/$(BOOT_OUT_DIR)/tim_dtim/tim_mk2-1063-1063-532-532-399-399-399-200__4_1_sm_400_1275mv_*_b0p.bin    $(OUTPUT_DIR)/mk2/emmc
	$(hide)cp $(SRC_DIR)/$(BOOT_OUT_DIR)/tim_dtim/tim_mk2-1196-1196-598-598-399-399-399-200__1p2g_1_sm_400_1275mv_*_b0p.bin $(OUTPUT_DIR)/mk2/emmc
	$(hide)cp $(SRC_DIR)/$(BOOT_OUT_DIR)/tim_dtim/Wtm_rel_mmp3.bin             $(OUTPUT_DIR)/mk2/emmc
	$(hide)cp $(SRC_DIR)/$(BOOT_OUT_DIR)/tim_dtim/Wtm_rel_mmp3_backup.bin      $(OUTPUT_DIR)/mk2/emmc
	$(hide)cp $(SRC_DIR)/$(BOOT_OUT_DIR)/tim_dtim/MMP3_LINUX_ARM_TZ.bin        $(OUTPUT_DIR)/mk2/emmc
	$(hide)cp $(SRC_DIR)/$(BOOT_OUT_DIR)/tim_dtim/MMP3_LINUX_ARM_TZ_backup.bin $(OUTPUT_DIR)/mk2/emmc
	$(hide)cp $(SRC_DIR)/$(BOOT_OUT_DIR)/tim_dtim/tzl.bin                      $(OUTPUT_DIR)/mk2/emmc
	$(hide)cp $(SRC_DIR)/$(BOOT_OUT_DIR)/tim_dtim/tzl_backup.bin               $(OUTPUT_DIR)/mk2/emmc
	$(hide)cp $(SRC_DIR)/$(BOOT_OUT_DIR)/tim_dtim/dtim_platform_primary.bin    $(OUTPUT_DIR)/mk2/emmc
	$(hide)cp $(SRC_DIR)/$(BOOT_OUT_DIR)/tim_dtim/dtim_platform_recovery.bin   $(OUTPUT_DIR)/mk2/emmc
	$(hide)cp $(SRC_DIR)/$(BOOT_OUT_DIR)/tim_dtim/u-boot.bin                   $(OUTPUT_DIR)/mk2/emmc
	$(hide)cp $(SRC_DIR)/$(BOOT_OUT_DIR)/tim_dtim/u-boot_recovery.bin          $(OUTPUT_DIR)/mk2/emmc

	$(hide)cp $(SRC_DIR)/device/marvell/mk2/development/* $(OUTPUT_DIR)/mk2/emmc/

	$(hide)mkdir -p $(OUTPUT_DIR)/mk2/emmc/EB_JO
	$(hide)cp $(SRC_DIR)/$(BOOT_OUT_DIR)/tim_product/EB_JO/tim_mk2-*.bin                $(OUTPUT_DIR)/mk2/emmc/EB_JO
	$(hide)cp $(SRC_DIR)/$(BOOT_OUT_DIR)/tim_product/EB_JO/MMP3_LINUX_ARM_TZ.bin        $(OUTPUT_DIR)/mk2/emmc/EB_JO
	$(hide)cp $(SRC_DIR)/$(BOOT_OUT_DIR)/tim_product/EB_JO/MMP3_LINUX_ARM_TZ_backup.bin $(OUTPUT_DIR)/mk2/emmc/EB_JO
	$(hide)cp $(SRC_DIR)/$(BOOT_OUT_DIR)/tim_product/EB_JO/Wtm_rel_mmp3_backup.bin      $(OUTPUT_DIR)/mk2/emmc/EB_JO
	$(hide)cp $(SRC_DIR)/$(BOOT_OUT_DIR)/tim_product/EB_JO/Wtm_rel_mmp3.bin             $(OUTPUT_DIR)/mk2/emmc/EB_JO

	$(hide)mkdir -p $(OUTPUT_DIR)/mk2/emmc/PB_JO
	$(hide)cp $(SRC_DIR)/$(BOOT_OUT_DIR)/tim_product/PB_JO/tim_mk2-*.bin                $(OUTPUT_DIR)/mk2/emmc/PB_JO
	$(hide)cp $(SRC_DIR)/$(BOOT_OUT_DIR)/tim_product/PB_JO/MMP3_LINUX_ARM_TZ.bin        $(OUTPUT_DIR)/mk2/emmc/PB_JO
	$(hide)cp $(SRC_DIR)/$(BOOT_OUT_DIR)/tim_product/PB_JO/MMP3_LINUX_ARM_TZ_backup.bin $(OUTPUT_DIR)/mk2/emmc/PB_JO
	$(hide)cp $(SRC_DIR)/$(BOOT_OUT_DIR)/tim_product/PB_JO/Wtm_rel_mmp3_backup.bin      $(OUTPUT_DIR)/mk2/emmc/PB_JO
	$(hide)cp $(SRC_DIR)/$(BOOT_OUT_DIR)/tim_product/PB_JO/Wtm_rel_mmp3.bin             $(OUTPUT_DIR)/mk2/emmc/PB_JO

	$(hide)mkdir -p $(OUTPUT_DIR)/mk2/emmc/PB
	$(hide)cp $(SRC_DIR)/$(BOOT_OUT_DIR)/tim_product/PB/tim_mk2-*.bin                $(OUTPUT_DIR)/mk2/emmc/PB
	$(hide)cp $(SRC_DIR)/$(BOOT_OUT_DIR)/tim_product/PB/MMP3_LINUX_ARM_TZ.bin        $(OUTPUT_DIR)/mk2/emmc/PB
	$(hide)cp $(SRC_DIR)/$(BOOT_OUT_DIR)/tim_product/PB/MMP3_LINUX_ARM_TZ_backup.bin $(OUTPUT_DIR)/mk2/emmc/PB
	$(hide)cp $(SRC_DIR)/$(BOOT_OUT_DIR)/tim_product/PB/Wtm_rel_mmp3_backup.bin      $(OUTPUT_DIR)/mk2/emmc/PB
	$(hide)cp $(SRC_DIR)/$(BOOT_OUT_DIR)/tim_product/PB/Wtm_rel_mmp3.bin             $(OUTPUT_DIR)/mk2/emmc/PB

	$(log) "[BOOTLOADER-mk2]Done:)"

.PHONY:clean_bootloader
clean_bootloader:
	$(log) "cleaning uboot and obm..."
	$(hide)cd $(SRC_DIR)/$(BOOT_SRC_DIR) && \
	make clean
	$(log) "    done."

build_device: bootloader

