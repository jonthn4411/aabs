#check if the required variables have been set.
$(call check-variables,BUILD_VARIANTS)
BOOT_SRC_DIR:=boot
BOOT_OUT_DIR:=$(BOOT_SRC_DIR)/out

#OBM_NTLOADER_1:=ASPN_NTLOADER_avengers-a_slc.bin
#OBM_NTLOADER_2:=ASPN_NTLOADER_spi.bin

OBM_NTIM_1:=TAVOR_LINUX_TOBM.bin
OBM_NTIM_ONENAND_1:=TAVOR_LINUX_TOBM_onenand.bin
#OBM_NTIM_1:=TAVOR_SAAR_NTOBM_EMMC_MODE1.bin.rnd
#OBM_NTIM_2:=ntim_a0_avengers-a_1.6F_256mb_400mhz_mode3_pm_spi.bin

MBR_BIN:=mbr


#$1:build variant
define define-build-uboot-obm
#format: <file name>:[m|o]:[md5]
#m:means mandatory
#o:means optional
#md5: need to generate md5 sum
PUBLISHING_FILES_$(1)+=$(1)/saarbmg_symbols.tgz:o:md5
PUBLISHING_FILES_$(1)+=$(1)/saarbmg1_bin.tgz:o:md5
PUBLISHING_FILES_$(1)+=$(1)/saarbmg2_bin.tgz:o:md5
PUBLISHING_FILES_$(1)+=$(1)/saarbmg_Diag_DB.tgz:o:md5


.PHONY:build_uboot_obm_$(1)
build_uboot_obm_$(1):
	$$(log) "starting($(1)) to build uboot and obm"
	$$(hide)cd $$(SRC_DIR)/$$(BOOT_SRC_DIR) && \
	make all

	$$(hide)mkdir -p $$(OUTPUT_DIR)/$(1)/saarbmg_symbols
	$$(hide)mkdir -p $$(OUTPUT_DIR)/$(1)/saarbmg1_bin
	$$(hide)mkdir -p $$(OUTPUT_DIR)/$(1)/saarbmg2_bin

	$$(log) "start to copy uboot and obm files"

	#-----------------------------
	# Copy Boot symbols
	#-----------------------------
	$$(hide)gzip -cf $$(SRC_DIR)/$$(BOOT_SRC_DIR)/uboot/u-boot > $$(OUTPUT_DIR)/$(1)/saarbmg_symbols/u-boot.gz
	
	#-----------------------------
	# copy saarbmg1 images
	#-----------------------------
	$$(hide)cp $$(SRC_DIR)/$$(BOOT_OUT_DIR)/u-boot.256k_recovery.saarb	 $$(OUTPUT_DIR)/$(1)/saarbmg1_bin
	$$(hide)cp $$(SRC_DIR)/$$(BOOT_OUT_DIR)/u-boot.256k.saarb			 $$(OUTPUT_DIR)/$(1)/saarbmg1_bin
	$$(hide)cp $$(SRC_DIR)/$$(BOOT_OUT_DIR)/obm.bin.saarbmg1			 $$(OUTPUT_DIR)/$(1)/saarbmg1_bin
	#-----------------------------
	# copy saarbmg2 images
	#-----------------------------
	$$(hide)cp $$(SRC_DIR)/$$(BOOT_OUT_DIR)/u-boot.256k_recovery.saarb	 $$(OUTPUT_DIR)/$(1)/saarbmg2_bin
	$$(hide)cp $$(SRC_DIR)/$$(BOOT_OUT_DIR)/u-boot.256k.saarb			 $$(OUTPUT_DIR)/$(1)/saarbmg2_bin
	$$(hide)cp $$(SRC_DIR)/$$(BOOT_OUT_DIR)/obm_2k.bin.saarbmg2			 $$(OUTPUT_DIR)/$(1)/saarbmg2_bin

	##$$(hide)cp $$(SRC_DIR)/out/target/product/$$(ABS_PRODUCT_NAME)/$$(MBR_BIN) $$(OUTPUT_DIR)/$(1)
	tar czf $$(OUTPUT_DIR)/$(1)/saarbmg_symbols 	saarbmg_symbols.tgz
	tar czf $$(OUTPUT_DIR)/$(1)/saarbmg1_bin		saarbmg1_bin.tgz
	tar czf $$(OUTPUT_DIR)/$(1)/saarbmg2_bin		saarbmg2_bin.tgz
	tar czf $$(OUTPUT_DIR)/$(1)/saarbmg_Diag_DB		saarbmg_Diag_DB.tgz
	$$(log) "  done."

endef

$(foreach bv, $(BUILD_VARIANTS), $(eval $(call define-build-uboot-obm,$(bv)) ) )

.PHONY:clean_uboot_obm
clean_uboot_obm:
	$(log) "cleaning uboot and obm..."
	$(hide)cd $(SRC_DIR)/$(BOOT_SRC_DIR) && \
	#make clean
	make clean_uboot
	$(log) "    done."



