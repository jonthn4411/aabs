#check if the required variables have been set.

$(call check-variables,BUILD_VARIANTS)
BOOT_SRC_DIR:=boot
BOOT_OUT_DIR:=$(BOOT_SRC_DIR)/out

#$1:build variant
define define-build-uboot-obm
#format: <file name>:[m|o]:[md5]
#m:means mandatory
#o:means optional
#md5: need to generate md5 sum
PUBLISHING_FILES_$(1)+=$(1)/u-boot.bin:m:md5
PUBLISHING_FILES_$(1)+=$(1)/u-boot_recovery.bin:m:md5
PUBLISHING_FILES_$(1)+=$(1)/Wtm_rel_mmp3.bin:m:md5
PUBLISHING_FILES_$(1)+=$(1)/Wtm_rel_mmp3_backup.bin:m:md5
PUBLISHING_FILES_$(1)+=$(1)/tzl.bin:m:md5
PUBLISHING_FILES_$(1)+=$(1)/tzl_backup.bin:m:md5
PUBLISHING_FILES_$(1)+=$(1)/trusted/MMP3_LINUX_ARM_3_3_1.bin:m:md5
PUBLISHING_FILES_$(1)+=$(1)/trusted/MMP3_LINUX_ARM_3_3_1_backup.bin:m:md5
PUBLISHING_FILES_$(1)+=$(1)/trusted/tim_mmp3_v7_mp_emmc_dis_uboot_800_backup.bin:m:md5
PUBLISHING_FILES_$(1)+=$(1)/trusted/tim_mmp3_v7_mp_emmc_dis_uboot_800_backup.txt:m:md5
PUBLISHING_FILES_$(1)+=$(1)/trusted/tim_mmp3_v7_mp_emmc_dis_uboot_800_primary.bin:m:md5
PUBLISHING_FILES_$(1)+=$(1)/trusted/tim_mmp3_v7_mp_emmc_dis_uboot_800_primary.txt:m:md5
PUBLISHING_FILES_$(1)+=$(1)/trusted/dtim_mmp3_v7_emmc_dis_uboot_800_primary.txt
PUBLISHING_FILES_$(1)+=$(1)/trusted/dtim_mmp3_v7_emmc_dis_uboot_800_backup.txt
PUBLISHING_FILES_$(1)+=$(1)/trusted/dtim_platform_backup.bin
PUBLISHING_FILES_$(1)+=$(1)/trusted/dtim_platform_primary.bin
PUBLISHING_FILES_$(1)+=$(1)/trusted/EncryptKey.txt
PUBLISHING_FILES_$(1)+=$(1)/nontrusted/MMP3_LINUX_ARM_3_3_1.bin:m:md5
PUBLISHING_FILES_$(1)+=$(1)/nontrusted/MMP3_LINUX_ARM_3_3_1_backup.bin:m:md5
PUBLISHING_FILES_$(1)+=$(1)/nontrusted/ntim_mmp3_v7_mp_emmc_dis_uboot_800_backup.bin
PUBLISHING_FILES_$(1)+=$(1)/nontrusted/ntim_mmp3_v7_mp_emmc_dis_uboot_800_backup.txt
PUBLISHING_FILES_$(1)+=$(1)/nontrusted/ntim_mmp3_v7_mp_emmc_dis_uboot_800_primary.bin
PUBLISHING_FILES_$(1)+=$(1)/nontrusted/ntim_mmp3_v7_mp_emmc_dis_uboot_800_primary.txt
PUBLISHING_FILES_$(1)+=$(1)/nontrusted/dntim_mmp3_v7_emmc_dis_uboot_800_backup.txt
PUBLISHING_FILES_$(1)+=$(1)/nontrusted/dntim_mmp3_v7_emmc_dis_uboot_800_primary.txt
PUBLISHING_FILES_$(1)+=$(1)/nontrusted/dntim_partition_backup.bin
PUBLISHING_FILES_$(1)+=$(1)/nontrusted/dntim_partition_primary.bin

.PHONY:build_uboot_obm_$(1)
build_uboot_obm_$(1):
	$$(log) "starting($(1)) to build uboot and obm"
	$$(hide)cd $$(SRC_DIR)/$$(BOOT_SRC_DIR) && \
	make trusted && \
	make nontrusted
	$$(hide)mkdir -p $$(OUTPUT_DIR)/$(1)/trusted
	$$(hide)mkdir -p $$(OUTPUT_DIR)/$(1)/nontrusted

	$$(log) "start to copy uboot and obm files"
	$$(hide)cp $$(SRC_DIR)/$$(BOOT_OUT_DIR)/u-boot.bin          $$(OUTPUT_DIR)/$(1)/
	$$(hide)cp $$(SRC_DIR)/$$(BOOT_OUT_DIR)/u-boot_recovery.bin $$(OUTPUT_DIR)/$(1)/
	$$(hide)cp $$(SRC_DIR)/boot/obm/binaries/Wtm_rel_mmp3.bin   $$(OUTPUT_DIR)/$(1)/
	$$(hide)cp $$(SRC_DIR)/boot/obm/binaries/Wtm_rel_mmp3.bin   $$(OUTPUT_DIR)/$(1)/
	$$(hide)cp $$(SRC_DIR)/boot/tzl/tzl.bin                     $$(OUTPUT_DIR)/$(1)/
	$$(hide)cp $$(SRC_DIR)/boot/tzl/tzl_backup.bin              $$(OUTPUT_DIR)/$(1)/
	$$(hide)cp $$(SRC_DIR)/boot/out/trusted/MMP3_LINUX_ARM_3_3_1.bin                      $$(OUTPUT_DIR)/$(1)/trusted
	$$(hide)cp $$(SRC_DIR)/boot/out/trusted/MMP3_LINUX_ARM_3_3_1_backup.bin               $$(OUTPUT_DIR)/$(1)/trusted
	$$(hide)cp $$(SRC_DIR)/boot/out/trusted/tim_mmp3_v7_mp_emmc_dis_uboot_800_backup.bin  $$(OUTPUT_DIR)/$(1)/trusted
	$$(hide)cp $$(SRC_DIR)/boot/out/trusted/tim_mmp3_v7_mp_emmc_dis_uboot_800_backup.txt  $$(OUTPUT_DIR)/$(1)/trusted
	$$(hide)cp $$(SRC_DIR)/boot/out/trusted/tim_mmp3_v7_mp_emmc_dis_uboot_800_primary.bin $$(OUTPUT_DIR)/$(1)/trusted
	$$(hide)cp $$(SRC_DIR)/boot/out/trusted/tim_mmp3_v7_mp_emmc_dis_uboot_800_primary.txt $$(OUTPUT_DIR)/$(1)/trusted
	$$(hide)cp $$(SRC_DIR)/boot/out/trusted/dtim_mmp3_v7_emmc_dis_uboot_800_primary.txt   $$(OUTPUT_DIR)/$(1)/trusted
	$$(hide)cp $$(SRC_DIR)/boot/out/trusted/dtim_mmp3_v7_emmc_dis_uboot_800_backup.txt    $$(OUTPUT_DIR)/$(1)/trusted
	$$(hide)cp $$(SRC_DIR)/boot/out/trusted/dtim_platform_backup.bin                      $$(OUTPUT_DIR)/$(1)/trusted
	$$(hide)cp $$(SRC_DIR)/boot/out/trusted/dtim_platform_primary.bin                     $$(OUTPUT_DIR)/$(1)/trusted
	$$(hide)cp $$(SRC_DIR)/boot/out/trusted/EncryptKey.txt                                $$(OUTPUT_DIR)/$(1)/trusted
	$$(hide)cp $$(SRC_DIR)/boot/out/nontrusted/MMP3_LINUX_ARM_3_3_1.bin                        $$(OUTPUT_DIR)/$(1)/nontrusted
	$$(hide)cp $$(SRC_DIR)/boot/out/nontrusted/MMP3_LINUX_ARM_3_3_1_backup.bin                 $$(OUTPUT_DIR)/$(1)/nontrusted
	$$(hide)cp $$(SRC_DIR)/boot/out/nontrusted/ntim_mmp3_v7_mp_emmc_dis_uboot_800_backup.bin   $$(OUTPUT_DIR)/$(1)/nontrusted
	$$(hide)cp $$(SRC_DIR)/boot/out/nontrusted/ntim_mmp3_v7_mp_emmc_dis_uboot_800_backup.txt   $$(OUTPUT_DIR)/$(1)/nontrusted
	$$(hide)cp $$(SRC_DIR)/boot/out/nontrusted/ntim_mmp3_v7_mp_emmc_dis_uboot_800_primary.bin  $$(OUTPUT_DIR)/$(1)/nontrusted
	$$(hide)cp $$(SRC_DIR)/boot/out/nontrusted/ntim_mmp3_v7_mp_emmc_dis_uboot_800_primary.txt  $$(OUTPUT_DIR)/$(1)/nontrusted
	$$(hide)cp $$(SRC_DIR)/boot/out/nontrusted/dntim_mmp3_v7_emmc_dis_uboot_800_backup.txt     $$(OUTPUT_DIR)/$(1)/nontrusted
	$$(hide)cp $$(SRC_DIR)/boot/out/nontrusted/dntim_mmp3_v7_emmc_dis_uboot_800_primary.txt    $$(OUTPUT_DIR)/$(1)/nontrusted
	$$(hide)cp $$(SRC_DIR)/boot/out/nontrusted/dntim_partition_backup.bin                      $$(OUTPUT_DIR)/$(1)/nontrusted
	$$(hide)cp $$(SRC_DIR)/boot/out/nontrusted/dntim_partition_primary.bin                     $$(OUTPUT_DIR)/$(1)/nontrusted
	$$(log) "uboot&obm done."

endef

$(foreach bv, $(BUILD_VARIANTS), $(eval $(call define-build-uboot-obm,$(bv)) ) )

.PHONY:clean_uboot_obm
clean_uboot_obm:
	$(log) "cleaning uboot and obm..."
	$(hide)cd $(SRC_DIR)/$(BOOT_SRC_DIR) && \
	make clean_uboot
	$(log) "    done."

