#check if the required variables have been set.
$(call check-variables,BUILD_VARIANTS)
BOOT_SRC_DIR:=boot
BOOT_OUT_DIR:=$(BOOT_SRC_DIR)/out
UBOOT:=u-boot.bin
OBM_NTIM_1:=ntim_mmp2_nand_bbu_ddr.bin
OBM_NTIM_DESC_1:=ntim_mmp2_emmc_ddr3_elipda_512m.txt
OBM_NTLOADER_1:=MMP2_NTLOADER_3_2_19.bin
OBM_TIM_1:=tim_mmp2_nand_bbu_ddr.bin
OBM_TIM_DESC_1:=tim_mmp2_emmc_ddr3_elipda_512m.txt
OBM_TLOADER_1:=MMP2_TLOADER_3_2_19.bin
WTM_1:=Wtm_rel_mmp2.bin
SW_DOWNLOADER:=SWDownloader_for_MMP2.rar

#$1:build variant
define define-build-uboot-obm
#format: <file name>:[m|o]:[md5]
#m:means mandatory
#o:means optional
#md5: need to generate md5 sum
PUBLISHING_FILES_$(1)+=$(1)/trusted/$(UBOOT):m:md5
PUBLISHING_FILES_$(1)+=$(1)/trusted/$(OBM_TLOADER_1):m:md5
PUBLISHING_FILES_$(1)+=$(1)/trusted/$(OBM_TIM_1):m:md5
PUBLISHING_FILES_$(1)+=$(1)/trusted/$(OBM_TIM_DESC_1):m:md5
PUBLISHING_FILES_$(1)+=$(1)/nontrusted/$(UBOOT):m:md5
PUBLISHING_FILES_$(1)+=$(1)/nontrusted/$(OBM_NTLOADER_1):m:md5
PUBLISHING_FILES_$(1)+=$(1)/nontrusted/$(OBM_NTIM_1):m:md5
PUBLISHING_FILES_$(1)+=$(1)/nontrusted/$(OBM_NTIM_DESC_1):m:md5
PUBLISHING_FILES_$(1)+=$(1)/$(WTM_1):m:md5
PUBLISHING_FILES_$(1)+=$(1)/$(SW_DOWNLOADER):m:md5

.PHONY:build_uboot_obm_$(1)
build_uboot_obm_$(1):
	$$(log) "starting($(1)) to build uboot and obm"
	$$(hide)cd $$(SRC_DIR)/$$(BOOT_SRC_DIR) && \
	make all
	$$(hide)mkdir -p $$(OUTPUT_DIR)/$(1)
	$$(hide)mkdir -p $$(OUTPUT_DIR)/$(1)/trusted
	$$(hide)mkdir -p $$(OUTPUT_DIR)/$(1)/nontrusted

	$$(log) "start to copy uboot and obm files"
	$$(hide)cp $$(SRC_DIR)/$$(BOOT_OUT_DIR)/$$(WTM_1) $$(OUTPUT_DIR)/$(1)
	$$(hide)cp $$(SRC_DIR)/$$(BOOT_OUT_DIR)/$$(SW_DOWNLOADER) $$(OUTPUT_DIR)/$(1)
	$$(hide)cp $$(SRC_DIR)/$$(BOOT_OUT_DIR)/trusted/$$(UBOOT) $$(OUTPUT_DIR)/$(1)/trusted
	$$(hide)cp $$(SRC_DIR)/$$(BOOT_OUT_DIR)/trusted/$$(OBM_TLOADER_1) $$(OUTPUT_DIR)/$(1)/trusted
	$$(hide)cp $$(SRC_DIR)/$$(BOOT_OUT_DIR)/trusted/$$(OBM_TIM_1) $$(OUTPUT_DIR)/$(1)/trusted
	$$(hide)cp $$(SRC_DIR)/$$(BOOT_OUT_DIR)/trusted/$$(OBM_TIM_DESC_1) $$(OUTPUT_DIR)/$(1)/trusted
	$$(hide)cp $$(SRC_DIR)/$$(BOOT_OUT_DIR)/nontrusted/$$(UBOOT) $$(OUTPUT_DIR)/$(1)/nontrusted
	$$(hide)cp $$(SRC_DIR)/$$(BOOT_OUT_DIR)/nontrusted/$$(OBM_NTLOADER_1) $$(OUTPUT_DIR)/$(1)/nontrusted
	$$(hide)cp $$(SRC_DIR)/$$(BOOT_OUT_DIR)/nontrusted/$$(OBM_NTIM_1) $$(OUTPUT_DIR)/$(1)/nontrusted
	$$(hide)cp $$(SRC_DIR)/$$(BOOT_OUT_DIR)/nontrusted/$$(OBM_NTIM_DESC_1) $$(OUTPUT_DIR)/$(1)/nontrusted
	$$(log) "  done."
endef

.PHONY:clean_uboot_obm
clean_uboot_obm:
	$(log) "cleaning uboot and obm..."
	$(hide)cd $(SRC_DIR)/$(BOOT_SRC_DIR) && \
	make clean
	$(log) "    done."
