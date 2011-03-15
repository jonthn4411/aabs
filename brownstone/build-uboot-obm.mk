#check if the required variables have been set.
$(call check-variables,BUILD_VARIANTS)
BOOT_SRC_DIR:=boot
BOOT_OUT_DIR:=$(BOOT_SRC_DIR)/out
UBOOT:=u-boot.bin
OBM_NTIM_1:=ntim_mmp2_nand_bbu_ddr.bin
OBM_NTIM_DESC_1:=ntim_mmp2_emmc_ddr3_elipda_1g.txt
OBM_NTLOADER_1:=MMP2_NTLOADER_3_2_19.bin
OBM_TIM_1:=tim_mmp2_nand_bbu_ddr.bin
OBM_TIM_DESC_1:=tim_mmp2_emmc_ddr3_elipda_1g.txt
OBM_TLOADER_1:=MMP2_TLOADER_3_2_19.bin
WTM_1:=Wtm_rel_mmp2.bin
PARTITION_BIN:=partition.bin
PARTITION_DESC:=partition.txt

#$1:build variant
define define-build-uboot-obm
#format: <file name>:[m|o]:[md5]
#m:means mandatory
#o:means optional
#md5: need to generate md5 sum
PUBLISHING_FILES+=$(1)/$(UBOOT):m:md5
PUBLISHING_FILES_$(1)+=$(1)/trusted/$(OBM_NTLOADER_1):m:md5
PUBLISHING_FILES_$(1)+=$(1)/trusted/$(OBM_NTIM_1):m:md5
PUBLISHING_FILES_$(1)+=$(1)/trusted/$(OBM_NTIM_DESC_1):m:md5
PUBLISHING_FILES_$(1)+=$(1)/trusted/$(PARTITION_BIN):m:md5
PUBLISHING_FILES_$(1)+=$(1)/trusted/$(PARTITION_DESC):m:md5
PUBLISHING_FILES_$(1)+=$(1)/nontrusted/$(OBM_TLOADER_1):m:md5
PUBLISHING_FILES_$(1)+=$(1)/nontrusted/$(OBM_TIM_1):m:md5
PUBLISHING_FILES_$(1)+=$(1)/nontrusted/$(OBM_TIM_DESC_1):m:md5
PUBLISHING_FILES_$(1)+=$(1)/nontrusted/$(PARTITION_BIN):m:md5
PUBLISHING_FILES_$(1)+=$(1)/nontrusted/$(PARTITION_DESC):m:md5
PUBLISHING_FILES_$(1)+=$(1)/$(WTM_1):m:md5

.PHONY:build_uboot_obm_$(1)
build_uboot_obm_$(1):
	$$(log) "starting($(1)) to build uboot and obm"
	$$(hide)cd $$(SRC_DIR)/$$(BOOT_SRC_DIR) && \
	make all
	$$(hide)mkdir -p $$(OUTPUT_DIR)/$(1)
	$$(hide)mkdir -p $$(OUTPUT_DIR)/$(1)/trusted
	$$(hide)mkdir -p $$(OUTPUT_DIR)/$(1)/nontrusted

	$$(log) "start to copy uboot and obm files"
	$$(hide)cp $$(SRC_DIR)/$$(BOOT_OUT_DIR)/u-boot.bin $$(OUTPUT_DIR)/$(1)
	$$(hide)cp $$(SRC_DIR)/$$(BOOT_OUT_DIR)/$$(WTM_1) $$(OUTPUT_DIR)/$(1)
	$$(hide)cp $$(SRC_DIR)/$$(BOOT_OUT_DIR)/trusted/$$(OBM_TLOADER_1) $$(OUTPUT_DIR)/$(1)/trusted
	$$(hide)cp $$(SRC_DIR)/$$(BOOT_OUT_DIR)/trusted/$$(OBM_TIM_1) $$(OUTPUT_DIR)/$(1)/trusted
	$$(hide)cp $$(SRC_DIR)/$$(BOOT_OUT_DIR)/trusted/$$(OBM_TIM_DESC_1) $$(OUTPUT_DIR)/$(1)/trusted
	$$(hide)cp $$(SRC_DIR)/$$(BOOT_OUT_DIR)/trusted/$$(PARTITION_BIN) $$(OUTPUT_DIR)/$(1)/trusted
	$$(hide)cp $$(SRC_DIR)/$$(BOOT_OUT_DIR)/trusted/$$(PARTITION_DESC) $$(OUTPUT_DIR)/$(1)/trusted
	$$(hide)cp $$(SRC_DIR)/$$(BOOT_OUT_DIR)/nontrusted/$$(OBM_NTLOADER_1) $$(OUTPUT_DIR)/$(1)/nontrusted
	$$(hide)cp $$(SRC_DIR)/$$(BOOT_OUT_DIR)/nontrusted/$$(OBM_NTIM_1) $$(OUTPUT_DIR)/$(1)/nontrusted
	$$(hide)cp $$(SRC_DIR)/$$(BOOT_OUT_DIR)/nontrusted/$$(OBM_NTIM_DESC_1) $$(OUTPUT_DIR)/$(1)/nontrusted
	$$(hide)cp $$(SRC_DIR)/$$(BOOT_OUT_DIR)/nontrusted/$$(PARTITION_BIN) $$(OUTPUT_DIR)/$(1)/nontrusted
	$$(hide)cp $$(SRC_DIR)/$$(BOOT_OUT_DIR)/nontrusted/$$(PARTITION_DESC) $$(OUTPUT_DIR)/$(1)/nontrusted
	$$(log) "  done."
endef

.PHONY:clean_uboot_obm
clean_uboot_obm:
	$(log) "cleaning uboot and obm..."
	$(hide)cd $(SRC_DIR)/$(BOOT_SRC_DIR) && \
	make clean
	$(log) "    done."
