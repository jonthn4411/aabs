
BOOT_SRC_DIR:=boot
BOOT_OUT_DIR:=$(BOOT_SRC_DIR)/out
BOOT_OUT_CM_DIR:=$(BOOT_OUT_DIR)/CM
BOOT_OUT_NOR_DIR:=$(BOOT_OUT_DIR)/NORMAL

PUBLISHING_FILES+=prebuilt/emmc/u-boot.bin:m:md5
PUBLISHING_FILES+=prebuilt/emmc/tim_mk2-1063-1063-532-532-399-399-399-200__4_1_sm_noch2_400_1250mv_primary.txt:m:md5
PUBLISHING_FILES+=prebuilt/emmc/tim_mk2-1063-1063-532-532-399-399-399-200__4_1_sm_noch2_400_1250mv_backup.txt:m:md5
PUBLISHING_FILES+=prebuilt/emmc/tim_mk2-1196-1196-598-598-399-399-399-200__1p2g_1_sm_noch2_400_1325mv_primary.txt:m:md5
PUBLISHING_FILES+=prebuilt/emmc/tim_mk2-1196-1196-598-598-399-399-399-200__1p2g_1_sm_noch2_400_1325mv_backup.txt:m:md5
PUBLISHING_FILES+=prebuilt/emmc/tim_mk2-1063-1063-532-532-399-399-399-200__4_1_sm_noch2_400_1250mv_backup.bin:m:md5
PUBLISHING_FILES+=prebuilt/emmc/tim_mk2-1063-1063-532-532-399-399-399-200__4_1_sm_noch2_400_1250mv_primary.bin:m:md5
PUBLISHING_FILES+=prebuilt/emmc/tim_mk2-1196-1196-598-598-399-399-399-200__1p2g_1_sm_noch2_400_1325mv_backup.bin:m:md5
PUBLISHING_FILES+=prebuilt/emmc/tim_mk2-1196-1196-598-598-399-399-399-200__1p2g_1_sm_noch2_400_1325mv_primary.bin:m:md5
PUBLISHING_FILES+=prebuilt/emmc/tim_mk2-1063-1063-532-532-399-399-399-200__4_1_sm_400_1275mv_primary_b0p.txt:m:md5
PUBLISHING_FILES+=prebuilt/emmc/tim_mk2-1063-1063-532-532-399-399-399-200__4_1_sm_400_1275mv_primary_b0p.bin:m:md5
PUBLISHING_FILES+=prebuilt/emmc/tim_mk2-1063-1063-532-532-399-399-399-200__4_1_sm_400_1275mv_backup_b0p.txt:m:md5
PUBLISHING_FILES+=prebuilt/emmc/tim_mk2-1063-1063-532-532-399-399-399-200__4_1_sm_400_1275mv_backup_b0p.bin:m:md5
PUBLISHING_FILES+=prebuilt/emmc/tim_mk2-1196-1196-598-598-399-399-399-200__1p2g_1_sm_400_1275mv_primary_b0p.txt:m:md5
PUBLISHING_FILES+=prebuilt/emmc/tim_mk2-1196-1196-598-598-399-399-399-200__1p2g_1_sm_400_1275mv_primary_b0p.bin:m:md5
PUBLISHING_FILES+=prebuilt/emmc/tim_mk2-1196-1196-598-598-399-399-399-200__1p2g_1_sm_400_1275mv_backup_b0p.txt:m:md5
PUBLISHING_FILES+=prebuilt/emmc/tim_mk2-1196-1196-598-598-399-399-399-200__1p2g_1_sm_400_1275mv_backup_b0p.bin:m:md5
PUBLISHING_FILES+=prebuilt/emmc/Wtm_rel_mmp3.bin:m:md5
PUBLISHING_FILES+=prebuilt/emmc/Wtm_rel_mmp3_backup.bin:m:md5
PUBLISHING_FILES+=prebuilt/emmc/MMP3_LINUX_ARM_NTZ.bin:m:md5
PUBLISHING_FILES+=prebuilt/emmc/MMP3_LINUX_ARM_NTZ_backup.bin:m:md5
PUBLISHING_FILES+=prebuilt/emmc/dtim_primary.txt:m:md5
PUBLISHING_FILES+=prebuilt/emmc/dtim_recovery.txt:m:md5
PUBLISHING_FILES+=prebuilt/emmc/dtim_platform_primary.bin:m:md5
PUBLISHING_FILES+=prebuilt/emmc/dtim_platform_recovery.bin:m:md5
PUBLISHING_FILES+=prebuilt/emmc/u-boot_recovery.bin:m:md5

PUBLISHING_FILES+=prebuilt/emmc/EB_JO/tim_mk2-1063-1063-532-532-399-399-399-200__4_1_sm_400_1275mv_backup_b0p.bin:m:md5
PUBLISHING_FILES+=prebuilt/emmc/EB_JO/tim_mk2-1063-1063-532-532-399-399-399-200__4_1_sm_400_1275mv_backup_b0p.txt:m:md5
PUBLISHING_FILES+=prebuilt/emmc/EB_JO/tim_mk2-1063-1063-532-532-399-399-399-200__4_1_sm_400_1275mv_primary_b0p.bin:m:md5
PUBLISHING_FILES+=prebuilt/emmc/EB_JO/tim_mk2-1063-1063-532-532-399-399-399-200__4_1_sm_400_1275mv_primary_b0p.txt:m:md5
PUBLISHING_FILES+=prebuilt/emmc/EB_JO/tim_mk2-1196-1196-598-598-399-399-399-200__1p2g_1_sm_400_1275mv_backup_b0p.bin:m:md5
PUBLISHING_FILES+=prebuilt/emmc/EB_JO/tim_mk2-1196-1196-598-598-399-399-399-200__1p2g_1_sm_400_1275mv_backup_b0p.txt:m:md5
PUBLISHING_FILES+=prebuilt/emmc/EB_JO/tim_mk2-1196-1196-598-598-399-399-399-200__1p2g_1_sm_400_1275mv_primary_b0p.bin:m:md5
PUBLISHING_FILES+=prebuilt/emmc/EB_JO/tim_mk2-1196-1196-598-598-399-399-399-200__1p2g_1_sm_400_1275mv_primary_b0p.txt:m:md5
PUBLISHING_FILES+=prebuilt/emmc/EB_JO/Wtm_rel_mmp3_backup.bin:m:md5
PUBLISHING_FILES+=prebuilt/emmc/EB_JO/Wtm_rel_mmp3.bin:m:md5
PUBLISHING_FILES+=prebuilt/emmc/EB_JO/MMP3_LINUX_ARM_NTZ_backup.bin:m:md5
PUBLISHING_FILES+=prebuilt/emmc/EB_JO/MMP3_LINUX_ARM_NTZ.bin:m:md5

PUBLISHING_FILES+=prebuilt/emmc/PB_JO/tim_mk2-1063-1063-532-532-399-399-399-200__4_1_sm_400_1275mv_backup_b0p.bin:m:md5
PUBLISHING_FILES+=prebuilt/emmc/PB_JO/tim_mk2-1063-1063-532-532-399-399-399-200__4_1_sm_400_1275mv_backup_b0p.txt:m:md5
PUBLISHING_FILES+=prebuilt/emmc/PB_JO/tim_mk2-1063-1063-532-532-399-399-399-200__4_1_sm_400_1275mv_primary_b0p.bin:m:md5
PUBLISHING_FILES+=prebuilt/emmc/PB_JO/tim_mk2-1063-1063-532-532-399-399-399-200__4_1_sm_400_1275mv_primary_b0p.txt:m:md5
PUBLISHING_FILES+=prebuilt/emmc/PB_JO/tim_mk2-1196-1196-598-598-399-399-399-200__1p2g_1_sm_400_1275mv_backup_b0p.bin:m:md5
PUBLISHING_FILES+=prebuilt/emmc/PB_JO/tim_mk2-1196-1196-598-598-399-399-399-200__1p2g_1_sm_400_1275mv_backup_b0p.txt:m:md5
PUBLISHING_FILES+=prebuilt/emmc/PB_JO/tim_mk2-1196-1196-598-598-399-399-399-200__1p2g_1_sm_400_1275mv_primary_b0p.bin:m:md5
PUBLISHING_FILES+=prebuilt/emmc/PB_JO/tim_mk2-1196-1196-598-598-399-399-399-200__1p2g_1_sm_400_1275mv_primary_b0p.txt:m:md5
PUBLISHING_FILES+=prebuilt/emmc/PB_JO/Wtm_rel_mmp3_backup.bin:m:md5
PUBLISHING_FILES+=prebuilt/emmc/PB_JO/Wtm_rel_mmp3.bin:m:md5
PUBLISHING_FILES+=prebuilt/emmc/PB_JO/MMP3_LINUX_ARM_NTZ_backup.bin:m:md5
PUBLISHING_FILES+=prebuilt/emmc/PB_JO/MMP3_LINUX_ARM_NTZ.bin:m:md5

PUBLISHING_FILES+=prebuilt/emmc/PB/tim_mk2-1063-1063-532-532-399-399-399-200__4_1_sm_400_1275mv_backup_b0p.bin:m:md5
PUBLISHING_FILES+=prebuilt/emmc/PB/tim_mk2-1063-1063-532-532-399-399-399-200__4_1_sm_400_1275mv_backup_b0p.txt:m:md5
PUBLISHING_FILES+=prebuilt/emmc/PB/tim_mk2-1063-1063-532-532-399-399-399-200__4_1_sm_400_1275mv_primary_b0p.bin:m:md5
PUBLISHING_FILES+=prebuilt/emmc/PB/tim_mk2-1063-1063-532-532-399-399-399-200__4_1_sm_400_1275mv_primary_b0p.txt:m:md5
PUBLISHING_FILES+=prebuilt/emmc/PB/tim_mk2-1196-1196-598-598-399-399-399-200__1p2g_1_sm_400_1275mv_backup_b0p.bin:m:md5
PUBLISHING_FILES+=prebuilt/emmc/PB/tim_mk2-1196-1196-598-598-399-399-399-200__1p2g_1_sm_400_1275mv_backup_b0p.txt:m:md5
PUBLISHING_FILES+=prebuilt/emmc/PB/tim_mk2-1196-1196-598-598-399-399-399-200__1p2g_1_sm_400_1275mv_primary_b0p.bin:m:md5
PUBLISHING_FILES+=prebuilt/emmc/PB/tim_mk2-1196-1196-598-598-399-399-399-200__1p2g_1_sm_400_1275mv_primary_b0p.txt:m:md5
PUBLISHING_FILES+=prebuilt/emmc/PB/Wtm_rel_mmp3_backup.bin:m:md5
PUBLISHING_FILES+=prebuilt/emmc/PB/Wtm_rel_mmp3.bin:m:md5
PUBLISHING_FILES+=prebuilt/emmc/PB/MMP3_LINUX_ARM_NTZ_backup.bin:m:md5
PUBLISHING_FILES+=prebuilt/emmc/PB/MMP3_LINUX_ARM_NTZ.bin:m:md5

PUBLISHING_FILES+=prebuilt/emmc/print_MMP3_FuseVal.xdb:m:md5
PUBLISHING_FILES+=prebuilt/emmc/PRE_SetupClocks.xdb:m:md5

.PHONY:bootloader
bootloader:
	$(log) "[BOOTLOADER]Starting to build all bootloader images"
	$(hide)cd $(SRC_DIR) && \
		source ./build/envsetup.sh && \
		chooseproduct $(ABS_DROID_PRODUCT) && choosetype $(ABS_DROID_TYPE) && choosevariant $(PLATFORM_ANDROID_VARIANT) && \
		cd $(SRC_DIR)/$(BOOT_SRC_DIR) && make all
	$(hide)mkdir -p $(OUTPUT_DIR)/prebuilt
	$(hide)mkdir -p $(OUTPUT_DIR)/prebuilt/emmc

	$(log) "start to copy uboot and obm files"
	$(hide)cp $(SRC_DIR)/$(BOOT_OUT_NOR_DIR)/u-boot.bin $(OUTPUT_DIR)/prebuilt/emmc
	$(hide)cp $(SRC_DIR)/$(BOOT_OUT_DIR)/tim_dtim/dtim_*.txt $(OUTPUT_DIR)/prebuilt/emmc
	$(hide)cp $(SRC_DIR)/$(BOOT_OUT_DIR)/tim_dtim/dtim_platform_*.bin $(OUTPUT_DIR)/prebuilt/emmc
	$(hide)cp $(SRC_DIR)/$(BOOT_OUT_DIR)/tim_dtim/u-boot_recovery.bin $(OUTPUT_DIR)/prebuilt/emmc
	$(hide)cp $(SRC_DIR)/$(BOOT_OUT_DIR)/tim_dtim/tim_mk2-1063-1063-532-532-399-399-399-200__4_1_sm_noch2_400_1250mv_*.*    $(OUTPUT_DIR)/prebuilt/emmc
	$(hide)cp $(SRC_DIR)/$(BOOT_OUT_DIR)/tim_dtim/tim_mk2-1196-1196-598-598-399-399-399-200__1p2g_1_sm_noch2_400_1325mv_*.* $(OUTPUT_DIR)/prebuilt/emmc
	$(hide)cp $(SRC_DIR)/$(BOOT_OUT_DIR)/tim_dtim/tim_mk2-1063-1063-532-532-399-399-399-200__4_1_sm_400_1275mv_*_b0p.*      $(OUTPUT_DIR)/prebuilt/emmc
	$(hide)cp $(SRC_DIR)/$(BOOT_OUT_DIR)/tim_dtim/tim_mk2-1196-1196-598-598-399-399-399-200__1p2g_1_sm_400_1275mv_*_b0p.*   $(OUTPUT_DIR)/prebuilt/emmc
	$(hide)cp $(SRC_DIR)/$(BOOT_OUT_DIR)/tim_dtim/Wtm_rel_mmp3.bin $(OUTPUT_DIR)/prebuilt/emmc
	$(hide)cp $(SRC_DIR)/$(BOOT_OUT_DIR)/tim_dtim/Wtm_rel_mmp3_backup.bin $(OUTPUT_DIR)/prebuilt/emmc
	$(hide)cp $(SRC_DIR)/$(BOOT_OUT_DIR)/tim_dtim/MMP3_LINUX_ARM_NTZ.bin $(OUTPUT_DIR)/prebuilt/emmc
	$(hide)cp $(SRC_DIR)/$(BOOT_OUT_DIR)/tim_dtim/MMP3_LINUX_ARM_NTZ_backup.bin $(OUTPUT_DIR)/prebuilt/emmc

	$(hide)cp $(SRC_DIR)/device/marvell/mk2/development/* $(OUTPUT_DIR)/prebuilt/emmc/

	$(hide)mkdir -p $(OUTPUT_DIR)/prebuilt/emmc/EB_JO
	$(hide)cp $(SRC_DIR)/$(BOOT_OUT_DIR)/tim_product/EB_JO/tim_mk2-*.*                   $(OUTPUT_DIR)/prebuilt/emmc/EB_JO
	$(hide)cp $(SRC_DIR)/$(BOOT_OUT_DIR)/tim_product/EB_JO/MMP3_LINUX_ARM_NTZ.bin        $(OUTPUT_DIR)/prebuilt/emmc/EB_JO
	$(hide)cp $(SRC_DIR)/$(BOOT_OUT_DIR)/tim_product/EB_JO/MMP3_LINUX_ARM_NTZ_backup.bin $(OUTPUT_DIR)/prebuilt/emmc/EB_JO
	$(hide)cp $(SRC_DIR)/$(BOOT_OUT_DIR)/tim_product/EB_JO/Wtm_rel_mmp3_backup.bin       $(OUTPUT_DIR)/prebuilt/emmc/EB_JO
	$(hide)cp $(SRC_DIR)/$(BOOT_OUT_DIR)/tim_product/EB_JO/Wtm_rel_mmp3.bin              $(OUTPUT_DIR)/prebuilt/emmc/EB_JO

	$(hide)mkdir -p $(OUTPUT_DIR)/prebuilt/emmc/PB_JO
	$(hide)cp $(SRC_DIR)/$(BOOT_OUT_DIR)/tim_product/PB_JO/tim_mk2-*.*                   $(OUTPUT_DIR)/prebuilt/emmc/PB_JO
	$(hide)cp $(SRC_DIR)/$(BOOT_OUT_DIR)/tim_product/PB_JO/MMP3_LINUX_ARM_NTZ.bin        $(OUTPUT_DIR)/prebuilt/emmc/PB_JO
	$(hide)cp $(SRC_DIR)/$(BOOT_OUT_DIR)/tim_product/PB_JO/MMP3_LINUX_ARM_NTZ_backup.bin $(OUTPUT_DIR)/prebuilt/emmc/PB_JO
	$(hide)cp $(SRC_DIR)/$(BOOT_OUT_DIR)/tim_product/PB_JO/Wtm_rel_mmp3_backup.bin       $(OUTPUT_DIR)/prebuilt/emmc/PB_JO
	$(hide)cp $(SRC_DIR)/$(BOOT_OUT_DIR)/tim_product/PB_JO/Wtm_rel_mmp3.bin              $(OUTPUT_DIR)/prebuilt/emmc/PB_JO

	$(hide)mkdir -p $(OUTPUT_DIR)/prebuilt/emmc/PB
	$(hide)cp $(SRC_DIR)/$(BOOT_OUT_DIR)/tim_product/PB/tim_mk2-*.*                   $(OUTPUT_DIR)/prebuilt/emmc/PB
	$(hide)cp $(SRC_DIR)/$(BOOT_OUT_DIR)/tim_product/PB/MMP3_LINUX_ARM_NTZ.bin        $(OUTPUT_DIR)/prebuilt/emmc/PB
	$(hide)cp $(SRC_DIR)/$(BOOT_OUT_DIR)/tim_product/PB/MMP3_LINUX_ARM_NTZ_backup.bin $(OUTPUT_DIR)/prebuilt/emmc/PB
	$(hide)cp $(SRC_DIR)/$(BOOT_OUT_DIR)/tim_product/PB/Wtm_rel_mmp3_backup.bin       $(OUTPUT_DIR)/prebuilt/emmc/PB
	$(hide)cp $(SRC_DIR)/$(BOOT_OUT_DIR)/tim_product/PB/Wtm_rel_mmp3.bin              $(OUTPUT_DIR)/prebuilt/emmc/PB

	$(log) "[BOOTLOADER]Done:)"

.PHONY:clean_bootloader
clean_bootloader:
	$(log) "cleaning uboot and obm..."
	$(hide)cd $(SRC_DIR)/$(BOOT_SRC_DIR) && \
	make clean
	$(log) "    done."

build_device: bootloader

