#check if the required variables have been set.
$(call check-variables,BUILD_VARIANTS)
BOOT_SRC_DIR:=boot
BOOT_OUT_DIR:=$(BOOT_SRC_DIR)/out
UBOOT:=u-boot.bin
OBM_NTIM_1:=ntim_mmp2_nand_bbu_ddr.bin
OBM_DESC_1:=ntim_mmp2_emmc_ddr_elipda_512m.txt
OBM_NTLOADER_1:=MMP2_NTLOADER_3_2_15.bin
WTM_1:=WtmUnresetPJ4.bin
PARTITION_BIN:=partition.bin
PARTITION_DESC:=partition.txt
OBM_NTIM_2:=ntim_mmp2_nand_bbu_ddr.bin
OBM_DESC_2:=ntim_mmp2_nand_bbu_ddr_elipda_512m.txt
OBM_NTLOADER_2:=MMP2_NTLOADER_3_2_15.bin
WTM_2:=WtmUnresetPJ4.bin
OBM_NTIM_3:=ntim_mmp2_nand_bbu_ddr.bin
OBM_DESC_3:=ntim_mmp2_emmc_ddr_elipda_512m.txt
OBM_NTLOADER_3:=MMP2_NTLOADER_3_2_17.bin
WTM_3:=WtmUnresetPJ4.bin
PARTITION_BIN_2:=partition.bin
PARTITION_DESC_2:=partition.txt
OBM_NTIM_4:=ntim_mmp2_nand_bbu_ddr.bin
OBM_DESC_4:=ntim_mmp2_nand_bbu_ddr_elipda_512m.txt
OBM_NTLOADER_4:=MMP2_NTLOADER_3_2_17.bin
WTM_4:=WtmUnresetPJ4.bin


#$1:build variant
define define-build-uboot-obm
#format: <file name>:[m|o]:[md5]
#m:means mandatory
#o:means optional
#md5: need to generate md5 sum
PUBLISHING_FILES+=$(1)/$(UBOOT):m:md5
PUBLISHING_FILES_$(1)+=$(1)/emmc/$(OBM_NTLOADER_1):m:md5
PUBLISHING_FILES_$(1)+=$(1)/emmc/$(OBM_NTIM_1):m:md5
PUBLISHING_FILES_$(1)+=$(1)/emmc/$(OBM_DESC_1):m:md5
PUBLISHING_FILES_$(1)+=$(1)/emmc/$(WTM_1):m:md5
PUBLISHING_FILES_$(1)+=$(1)/emmc/$(PARTITION_BIN):m:md5
PUBLISHING_FILES_$(1)+=$(1)/emmc/$(PARTITION_DESC):m:md5
PUBLISHING_FILES_$(1)+=$(1)/nand/$(OBM_NTLOADER_2):m:md5
PUBLISHING_FILES_$(1)+=$(1)/nand/$(OBM_NTIM_2):m:md5
PUBLISHING_FILES_$(1)+=$(1)/nand/$(OBM_DESC_2):m:md5
PUBLISHING_FILES_$(1)+=$(1)/nand/$(WTM_2):m:md5
PUBLISHING_FILES_$(1)+=$(1)/emmc-3.2.18/$(OBM_NTLOADER_3):m:md5
PUBLISHING_FILES_$(1)+=$(1)/emmc-3.2.18/$(OBM_NTIM_3):m:md5
PUBLISHING_FILES_$(1)+=$(1)/emmc-3.2.18/$(OBM_DESC_3):m:md5
PUBLISHING_FILES_$(1)+=$(1)/emmc-3.2.18/$(WTM_3):m:md5
PUBLISHING_FILES_$(1)+=$(1)/emmc-3.2.18/$(PARTITION_BIN_2):m:md5
PUBLISHING_FILES_$(1)+=$(1)/emmc-3.2.18/$(PARTITION_DESC_2):m:md5
PUBLISHING_FILES_$(1)+=$(1)/nand-3.2.18/$(OBM_NTLOADER_4):m:md5
PUBLISHING_FILES_$(1)+=$(1)/nand-3.2.18/$(OBM_NTIM_4):m:md5
PUBLISHING_FILES_$(1)+=$(1)/nand-3.2.18/$(OBM_DESC_4):m:md5
PUBLISHING_FILES_$(1)+=$(1)/nand-3.2.18/$(WTM_4):m:md5



.PHONY:build_uboot_obm_$(1)
build_uboot_obm_$(1):
	$$(log) "starting($(1)) to build uboot and obm"
	$$(hide)cd $$(SRC_DIR)/$$(BOOT_SRC_DIR) && \
	make all
	$$(hide)mkdir -p $$(OUTPUT_DIR)/$(1)
	$$(hide)mkdir -p $$(OUTPUT_DIR)/$(1)/nand
	$$(hide)mkdir -p $$(OUTPUT_DIR)/$(1)/emmc

	$$(log) "start to copy uboot and obm files"
	$$(hide)cp $$(SRC_DIR)/$$(BOOT_OUT_DIR)/u-boot.bin $$(OUTPUT_DIR)/$(1)
	$$(hide)cp $$(SRC_DIR)/$$(BOOT_OUT_DIR)/emmc/$$(OBM_NTLOADER_1) $$(OUTPUT_DIR)/$(1)/emmc
	$$(hide)cp $$(SRC_DIR)/$$(BOOT_OUT_DIR)/emmc/$$(OBM_NTIM_1) $$(OUTPUT_DIR)/$(1)/emmc
	$$(hide)cp $$(SRC_DIR)/$$(BOOT_OUT_DIR)/emmc/$$(OBM_DESC_1) $$(OUTPUT_DIR)/$(1)/emmc
	$$(hide)cp $$(SRC_DIR)/$$(BOOT_OUT_DIR)/emmc/$$(WTM_1) $$(OUTPUT_DIR)/$(1)/emmc
	$$(hide)cp $$(SRC_DIR)/$$(BOOT_OUT_DIR)/emmc/$$(PARTITION_BIN) $$(OUTPUT_DIR)/$(1)/emmc
	$$(hide)cp $$(SRC_DIR)/$$(BOOT_OUT_DIR)/emmc/$$(PARTITION_DESC) $$(OUTPUT_DIR)/$(1)/emmc
	$$(hide)cp $$(SRC_DIR)/$$(BOOT_OUT_DIR)/nand/$$(OBM_NTLOADER_2) $$(OUTPUT_DIR)/$(1)/nand
	$$(hide)cp $$(SRC_DIR)/$$(BOOT_OUT_DIR)/nand/$$(OBM_NTIM_2) $$(OUTPUT_DIR)/$(1)/nand
	$$(hide)cp $$(SRC_DIR)/$$(BOOT_OUT_DIR)/nand/$$(OBM_DESC_2) $$(OUTPUT_DIR)/$(1)/nand
	$$(hide)cp $$(SRC_DIR)/$$(BOOT_OUT_DIR)/nand/$$(WTM_2) $$(OUTPUT_DIR)/$(1)/nand
	$$(hide)cp $$(SRC_DIR)/$$(BOOT_OUT_DIR)/emmc-3.2.18/$$(OBM_NTLOADER_3) $$(OUTPUT_DIR)/$(1)/emmc-3.2.18
	$$(hide)cp $$(SRC_DIR)/$$(BOOT_OUT_DIR)/emmc-3.2.18/$$(OBM_NTIM_3) $$(OUTPUT_DIR)/$(1)/emmc-3.2.18
	$$(hide)cp $$(SRC_DIR)/$$(BOOT_OUT_DIR)/emmc-3.2.18/$$(OBM_DESC_3) $$(OUTPUT_DIR)/$(1)/emmc-3.2.18
	$$(hide)cp $$(SRC_DIR)/$$(BOOT_OUT_DIR)/emmc-3.2.18/$$(WTM_3) $$(OUTPUT_DIR)/$(1)/emmc-3.2.18
	$$(hide)cp $$(SRC_DIR)/$$(BOOT_OUT_DIR)/emmc-3.2.18/$$(PARTITION_BIN_2) $$(OUTPUT_DIR)/$(1)/emmc-3.2.18
	$$(hide)cp $$(SRC_DIR)/$$(BOOT_OUT_DIR)/emmc-3.2.18/$$(PARTITION_DESC_2) $$(OUTPUT_DIR)/$(1)/emmc-3.2.18
	$$(hide)cp $$(SRC_DIR)/$$(BOOT_OUT_DIR)/nand-3.2.18/$$(OBM_NTLOADER_4) $$(OUTPUT_DIR)/$(1)/nand-3.2.18
	$$(hide)cp $$(SRC_DIR)/$$(BOOT_OUT_DIR)/nand-3.2.18/$$(OBM_NTIM_4) $$(OUTPUT_DIR)/$(1)/nand-3.2.18
	$$(hide)cp $$(SRC_DIR)/$$(BOOT_OUT_DIR)/nand-3.2.18/$$(OBM_DESC_4) $$(OUTPUT_DIR)/$(1)/nand-3.2.18
	$$(hide)cp $$(SRC_DIR)/$$(BOOT_OUT_DIR)/nand-3.2.18/$$(WTM_4) $$(OUTPUT_DIR)/$(1)/nand-3.2.18
	$$(log) "  done."

endef

$(foreach bv, $(BUILD_VARIANTS), $(eval $(call define-build-uboot-obm,$(bv)) ) )

.PHONY:clean_uboot_obm
clean_uboot_obm:
	$(log) "cleaning uboot and obm..."
	$(hide)cd $(SRC_DIR)/$(BOOT_SRC_DIR) && \
	make clean
	$(log) "    done."




