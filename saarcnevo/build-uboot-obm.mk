#check if the required variables have been set.
$(call check-variables,BUILD_VARIANTS)
BOOT_SRC_DIR:=boot
BOOT_OUT_DIR:=$(BOOT_SRC_DIR)/out

#OBM_NTLOADER_1:=ASPN_NTLOADER_avengers-a_slc.bin
#OBM_NTLOADER_2:=ASPN_NTLOADER_spi.bin

OBM_NTIM_1:=TAVOR_LINUX_TOBM.bin
OBM_NTIM_2:=PinMuxData.bin
#OBM_NTIM_1:=TAVOR_SAAR_NTOBM_EMMC_MODE1.bin.rnd
#OBM_NTIM_2:=ntim_a0_avengers-a_1.6F_256mb_400mhz_mode3_pm_spi.bin

PRIMARY_GPT_BIN:=primary_gpt
SECONDARY_GPT_BIN:=secondary_gpt

ifneq ($(ANDROID_VERSION),ics)
DROID_PRODUCT:=saarcnevo
else
DROID_PRODUCT:=nevo
endif

#$1:build variant
define define-build-uboot-obm
#format: <file name>:[m|o]:[md5]
#m:means mandatory
#o:means optional
#md5: need to generate md5 sum
PUBLISHING_FILES_$(1)+=$(1)/u-boot.bin:m:md5
#PUBLISHING_FILES_$(1)+=$(1)/$(OBM_NTIM_1):m:md5
#PUBLISHING_FILES_$(1)+=$(1)/$(OBM_NTIM_2):m:md5
#PUBLISHING_FILES_$(1)+=$(1)/$(OBM_NTLOADER_1):m:md5
PUBLISHING_FILES_$(1)+=$(1)/$(PRIMARY_GPT_BIN):m:md5
PUBLISHING_FILES_$(1)+=$(1)/$(SECONDARY_GPT_BIN):m:md5


.PHONY:build_uboot_obm_$(1)
build_uboot_obm_$(1):
	$$(log) "starting($(1)) to build uboot and obm"
	$$(hide)cd $$(SRC_DIR)/$$(BOOT_SRC_DIR) && \
	make all
	$$(hide)mkdir -p $$(OUTPUT_DIR)/$(1)

	$$(log) "start to copy uboot and obm files"
	$$(hide)cp $$(SRC_DIR)/$$(BOOT_OUT_DIR)/u-boot.bin $$(OUTPUT_DIR)/$(1)
	#$$(hide)cp $$(SRC_DIR)/$$(BOOT_OUT_DIR)/$$(OBM_NTLOADER_1) $$(OUTPUT_DIR)/$(1)
	$$(hide)cp $$(SRC_DIR)/$$(BOOT_OUT_DIR)/$$(OBM_NTIM_1) $$(OUTPUT_DIR)/$(1)
	$$(hide)cp $$(SRC_DIR)/$$(BOOT_OUT_DIR)/$$(OBM_NTIM_2) $$(OUTPUT_DIR)/$(1)
	#$$(hide)cp $$(SRC_DIR)/out/target/product/$$(DROID_PRODUCT)/$$(OBM_NTIM_1) $$(OUTPUT_DIR)/$(1)
	$$(hide)if [ -e $$(SRC_DIR)/out/target/product/$$(DROID_PRODUCT)/$$(PRIMARY_GPT_BIN) ]; then cp $$(SRC_DIR)/out/target/product/$$(DROID_PRODUCT)/$$(PRIMARY_GPT_BIN) $$(OUTPUT_DIR)/$(1); fi
	$$(hide)if [ -e $$(SRC_DIR)/out/target/product/$$(DROID_PRODUCT)/$$(SECONDARY_GPT_BIN) ]; then cp $$(SRC_DIR)/out/target/product/$$(DROID_PRODUCT)/$$(SECONDARY_GPT_BIN) $$(OUTPUT_DIR)/$(1); fi
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



