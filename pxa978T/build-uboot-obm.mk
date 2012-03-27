#check if the required variables have been set.
#$(call check-variables,BUILD_VARIANTS)
BOOT_SRC_DIR:=boot
BOOT_OUT_DIR:=$(BOOT_SRC_DIR)/out

#OBM_NTLOADER_1:=ASPN_NTLOADER_avengers-a_slc.bin
#OBM_NTLOADER_2:=ASPN_NTLOADER_spi.bin

OBM_NTIM_1:=NEVO_Loader_eMMC_ARM_3_3_1.bin
#OBM_NTIM_1:=TAVOR_SAAR_NTOBM_EMMC_MODE1.bin.rnd
#OBM_NTIM_2:=ntim_a0_avengers-a_1.6F_256mb_400mhz_mode3_pm_spi.bin

PRIMARY_GPT_BIN:=primary_gpt
SECONDARY_GPT_BIN:=secondary_gpt
PRIMARY_GPT_BIN_2:=primary_gpt_8g
SECONDARY_GPT_BIN_2:=secondary_gpt_8g

PRODUCT_OUT:=common
#format: <file name>:<dst folder>:[m|o]:[md5]
#m:means mandatory
#o:means optional
#md5: need to generate md5 sum
PUBLISHING_FILES2+=u-boot.bin:$(PRODUCT_OUT):m:md5
PUBLISHING_FILES2+=$(PRIMARY_GPT_BIN):$(PRODUCT_OUT):m:md5
PUBLISHING_FILES2+=$(SECONDARY_GPT_BIN):$(PRODUCT_OUT):m:md5
PUBLISHING_FILES2+=$(PRIMARY_GPT_BIN_2):$(PRODUCT_OUT):m:md5
PUBLISHING_FILES2+=$(SECONDARY_GPT_BIN_2):$(PRODUCT_OUT):m:md5
PUBLISHING_FILES2+=$(OBM_NTIM_1):$(PRODUCT_OUT):m:md5

.PHONY:build_uboot_obm
build_uboot_obm):
	$(log) "starting to build uboot and obm"
	$(hide)cd $(SRC_DIR)/$(BOOT_SRC_DIR) && \
	make all
	$(hide)mkdir -p $(OUTPUT_DIR)/

	$(log) "start to copy uboot and obm files"
	$(hide)cp $(SRC_DIR)/$(BOOT_OUT_DIR)/u-boot.bin $(OUTPUT_DIR)/
	$(hide)if [ -e $(SRC_DIR)/$(BOOT_OUT_DIR)/$(OBM_NTIM_1) ]; then cp $(SRC_DIR)/$(BOOT_OUT_DIR)/$(OBM_NTIM_1) $(OUTPUT_DIR)); fi
	#$$(hide)cp $$(SRC_DIR)/out/target/product/$$(DROID_PRODUCT)/$$(OBM_NTIM_1) $$(OUTPUT_DIR)/$(1)
	$$(hide)if [ -e $$(SRC_DIR)/out/target/product/$$(DROID_PRODUCT)/$$(PRIMARY_GPT_BIN) ]; then cp $$(SRC_DIR)/out/target/product/$$(DROID_PRODUCT)/$$(PRIMARY_GPT_BIN) $$(OUTPUT_DIR)/; fi
	$$(hide)if [ -e $$(SRC_DIR)/out/target/product/$$(DROID_PRODUCT)/$$(SECONDARY_GPT_BIN) ]; then cp $$(SRC_DIR)/out/target/product/$$(DROID_PRODUCT)/$$(SECONDARY_GPT_BIN) $$(OUTPUT_DIR)/; fi
	$$(hide)if [ -e $$(SRC_DIR)/out/target/product/$$(DROID_PRODUCT)/$$(PRIMARY_GPT_BIN_2) ]; then cp $$(SRC_DIR)/out/target/product/$$(DROID_PRODUCT)/$$(PRIMARY_GPT_BIN_2) $$(OUTPUT_DIR)/; fi
	$$(hide)if [ -e $$(SRC_DIR)/out/target/product/$$(DROID_PRODUCT)/$$(SECONDARY_GPT_BIN_2) ]; then cp $$(SRC_DIR)/out/target/product/$$(DROID_PRODUCT)/$$(SECONDARY_GPT_BIN_2) $$(OUTPUT_DIR)/; fi
	$$(log) "  done."

endef

.PHONY:clean_uboot_obm
clean_uboot_obm:
	$(log) "cleaning uboot and obm..."
	$(hide)cd $(SRC_DIR)/$(BOOT_SRC_DIR) && \
	#make clean
	make clean_uboot
	$(log) "    done."



