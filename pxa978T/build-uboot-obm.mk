#check if the required variables have been set.
#$(call check-variables,BUILD_VARIANTS)
BOOT_SRC_DIR:=boot
BOOT_OUT_DIR:=$(BOOT_SRC_DIR)/out

#OBM_NTLOADER_1:=ASPN_NTLOADER_avengers-a_slc.bin
#OBM_NTLOADER_2:=ASPN_NTLOADER_spi.bin

OBM_NTIM_1:=NEVO_NTLoader_eMMC_DDR533_ARM_3_3_1.bin
OBM_NTIM_2:=NEVO_NTLoader_eMMC_DDR400_ARM_3_3_1.bin
OBM_NTIM_3:=NEVO_TLoader_eMMC_DDR533_ARM_3_3_1.bin
OBM_NTIM_4:=NEVO_TLoader_eMMC_DDR400_ARM_3_3_1.bin

PRIMARY_GPT_BIN:=primary_gpt
SECONDARY_GPT_BIN:=secondary_gpt
PRIMARY_GPT_BIN_2:=primary_gpt_8g
SECONDARY_GPT_BIN_2:=secondary_gpt_8g

PRODUCT_OUT:=common
#format: <file name>:<dst folder>:[m|o]:[md5]
#m:means mandatory
#o:means optional
#md5: need to generate md5 sum

define define-build-uboot-obm-target
tw:=$$(subst :,  , $(1) )
product:=$$(word 1, $$(tw) )
device:=$$(word 2, $$(tw) )
.PHONY:build_uboot_obm_$$(product)
build_uboot_obm_$$(product): private_product:=$$(product)
build_uboot_obm_$$(product): private_device:=$$(device)
build_uboot_obm_$$(product): build_telephony_$$(product)
	$(log) "[$$(private_product])starting to build uboot and obm"
	$(hide)cd $(SRC_DIR) && \
	source ./build/envsetup.sh && \
	chooseproduct $$(private_product) && choosetype $(DROID_TYPE) && choosevariant $(DROID_VARIANT) && \
	cd $(SRC_DIR)/$(BOOT_SRC_DIR) && \
	make all
	$(hide)mkdir -p $(OUTPUT_DIR)/$$(private_product)

	$(log) "start to copy uboot and obm files"
	$(hide)cp $(SRC_DIR)/$(BOOT_OUT_DIR)/u-boot.bin $(OUTPUT_DIR)/$$(private_product)
	$(hide)if [ -e $(SRC_DIR)/$(BOOT_OUT_DIR)/$(OBM_NTIM_1) ]; then cp $(SRC_DIR)/$(BOOT_OUT_DIR)/$(OBM_NTIM_1) $(OUTPUT_DIR)/$$(private_product); fi
	$(hide)if [ -e $(SRC_DIR)/$(BOOT_OUT_DIR)/$(OBM_NTIM_2) ]; then cp $(SRC_DIR)/$(BOOT_OUT_DIR)/$(OBM_NTIM_2) $(OUTPUT_DIR)/$$(private_product); fi
	$(hide)if [ -e $(SRC_DIR)/$(BOOT_OUT_DIR)/$(OBM_NTIM_3) ]; then cp $(SRC_DIR)/$(BOOT_OUT_DIR)/$(OBM_NTIM_3) $(OUTPUT_DIR)/$$(private_product); fi
	$(hide)if [ -e $(SRC_DIR)/$(BOOT_OUT_DIR)/$(OBM_NTIM_4) ]; then cp $(SRC_DIR)/$(BOOT_OUT_DIR)/$(OBM_NTIM_4) $(OUTPUT_DIR)/$$(private_product); fi
	$$(hide)if [ -e $$(SRC_DIR)/out/target/product/$$(private_device)/$$(PRIMARY_GPT_BIN) ]; then cp $$(SRC_DIR)/out/target/product/$$(private_device)/$$(PRIMARY_GPT_BIN) $$(OUTPUT_DIR)/$$(private_product); fi
	$$(hide)if [ -e $$(SRC_DIR)/out/target/product/$$(private_device)/$$(SECONDARY_GPT_BIN) ]; then cp $$(SRC_DIR)/out/target/product/$$(private_device)/$$(SECONDARY_GPT_BIN) $$(OUTPUT_DIR)/$$(private_product); fi
	$$(hide)if [ -e $$(SRC_DIR)/out/target/product/$$(private_device)/$$(PRIMARY_GPT_BIN_2) ]; then cp $$(SRC_DIR)/out/target/product/$$(private_device)/$$(PRIMARY_GPT_BIN_2) $$(OUTPUT_DIR)/$$(private_product); fi
	$$(hide)if [ -e $$(SRC_DIR)/out/target/product/$$(private_device)/$$(SECONDARY_GPT_BIN_2) ]; then cp $$(SRC_DIR)/out/target/product/$$(private_device)/$$(SECONDARY_GPT_BIN_2) $$(OUTPUT_DIR)/$$(private_product); fi
	$$(log) "  done."
PUBLISHING_FILES+=$$(product)/u-boot.bin:m:md5
PUBLISHING_FILES+=$$(product)/$(PRIMARY_GPT_BIN):m:md5
PUBLISHING_FILES+=$$(product)/$(SECONDARY_GPT_BIN):m:md5
PUBLISHING_FILES+=$$(product)/$(PRIMARY_GPT_BIN_2):m:md5
PUBLISHING_FILES+=$$(product)/$(SECONDARY_GPT_BIN_2):m:md5
PUBLISHING_FILES+=$$(product)/$(OBM_NTIM_1):m:md5
PUBLISHING_FILES+=$$(product)/$(OBM_NTIM_2):m:md5
PUBLISHING_FILES+=$$(product)/$(OBM_NTIM_3):m:md5
PUBLISHING_FILES+=$$(product)/$(OBM_NTIM_4):m:md5

endef

define define-clean-uboot-obm-target
tw:=$$(subst :,  , $(1) )
product:=$$(word 1, $$(tw) )
device:=$$(word 2, $$(tw) )
.PHONY:clean_uboot_obm_$$(product)
clean_uboot_obm_$$(product): private_product:=$$(product)
clean_uboot_obm_$$(product): private_device:=$$(device)
clean_uboot_obm_$$(product):
	$(log) "cleaning uboot and obm..."
	source ./build/envsetup.sh && \
	chooseproduct $$(private_product) && choosetype $(DROID_TYPE) && choosevariant $(DROID_VARIANT) && \
	cd $(SRC_DIR)/$(BOOT_SRC_DIR) && \
	#make clean
	make clean_uboot
	$(log) "    done."
endef

$(foreach bv, $(ABS_BUILD_DEVICES), $(eval $(call define-build-uboot-obm-target,$(bv)) ))
$(foreach bv, $(ABS_BUILD_DEVICES), $(eval $(call define-clean-uboot-obm-target,$(bv)) ))


