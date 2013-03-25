BOOT_SRC_DIR:=boot
BOOT_OUT_DIR:=$(BOOT_SRC_DIR)/out
UBOOT:=u-boot.bin

OBM_NTIM_1:=ntim_platform_512m_ddr3.bin
OBM_NTIM_DESC_1:=ntim_platform_512m_ddr3.txt
OBM_NTLOADER_1:=MMP2_LINUX_ARM_BL_3_2_21_EB_JO.bin
OBM_DNTIM_1:=dntim_platform.bin
OBM_DNTIM_DESC_1:=dntim_platform.txt
OBM_DNTIM_DESC_2:=dntim_platform_uImage.txt

OBM_TIM_1:=tim_platform_512m_ddr3.bin
OBM_TIM_DESC_1:=tim_platform_512m_ddr3.txt
OBM_TLOADER_1:=MMP2_LINUX_ARM_BL_3_2_21_TRUSTED_EB_JO.bin
OBM_DTIM_1:=dtim_platform.bin
OBM_DTIM_DESC_1:=dtim_platform.txt
OBM_DTIM_DESC_2:=dtim_platform_uImage.txt
OBM_DTIM_KEY_1:=EncryptKey.txt

WTM_1:=Wtm_rel_mmp2.bin

#$1:build variant
define define-build-uboot-obm
tw:=$$(subst :,  , $(1))
product:=$$(word 1, $$(tw))
device:=$$(word 2, $$(tw))

#format: <file name>:[m|o]:[md5]
#m:means mandatory
#o:means optional
#md5: need to generate md5 sum
PUBLISHING_FILES+=$$(product)/trusted/$(UBOOT):m:md5
PUBLISHING_FILES+=$$(product)/trusted/$(OBM_TLOADER_1):m:md5
PUBLISHING_FILES+=$$(product)/trusted/$(OBM_TIM_1):m:md5
PUBLISHING_FILES+=$$(product)/trusted/$(OBM_TIM_DESC_1):m:md5
PUBLISHING_FILES+=$$(product)/trusted/$(OBM_DTIM_1):m:md5
PUBLISHING_FILES+=$$(product)/trusted/$(OBM_DTIM_DESC_1):o:md5
PUBLISHING_FILES+=$$(product)/trusted/$(OBM_DTIM_DESC_2):o:md5
PUBLISHING_FILES+=$$(product)/trusted/$(OBM_DTIM_KEY_1):m:md5
PUBLISHING_FILES+=$$(product)/nontrusted/$(UBOOT):m:md5
PUBLISHING_FILES+=$$(product)/nontrusted/$(OBM_NTLOADER_1):m:md5
PUBLISHING_FILES+=$$(product)/nontrusted/$(OBM_NTIM_1):m:md5
PUBLISHING_FILES+=$$(product)/nontrusted/$(OBM_NTIM_DESC_1):m:md5
PUBLISHING_FILES+=$$(product)/nontrusted/$(OBM_DNTIM_1):m:md5
PUBLISHING_FILES+=$$(product)/nontrusted/$(OBM_DNTIM_DESC_1):o:md5
PUBLISHING_FILES+=$$(product)/nontrusted/$(OBM_DNTIM_DESC_2):o:md5
PUBLISHING_FILES+=$$(product)/$(WTM_1):m:md5

.PHONY:build_uboot_obm_$$(product)
build_uboot_obm_$$(product): private_product:=$$(product)
build_uboot_obm_$$(product): private_device:=$$(device)
build_uboot_obm_$$(product): build_droid_root_$$(product)
	$$(log) "starting($$(private_product) to build uboot and obm"
	$$(hide)cd $$(SRC_DIR) && \
	. $$(ABS_TOP_DIR)/tools/apb $$(private_product) && \
	choosetype $$(DROID_TYPE) && choosevariant $$(DROID_VARIANT) && \
	cd $$(BOOT_SRC_DIR) && \
	make all
	$$(hide)mkdir -p $$(OUTPUT_DIR)/$$(private_product)/trusted
	$$(hide)mkdir -p $$(OUTPUT_DIR)/$$(private_product)/nontrusted
	$$(log) "start to copy uboot and obm files"
	$$(hide)cp $$(SRC_DIR)/$$(BOOT_OUT_DIR)/$$(WTM_1) $$(OUTPUT_DIR)/$$(private_product)
	$$(hide)cp $$(SRC_DIR)/$$(BOOT_OUT_DIR)/trusted/$$(UBOOT) $$(OUTPUT_DIR)/$$(private_product)/trusted
	$$(hide)cp $$(SRC_DIR)/$$(BOOT_OUT_DIR)/trusted/$$(OBM_TLOADER_1) $$(OUTPUT_DIR)/$$(private_product)/trusted
	$$(hide)cp $$(SRC_DIR)/$$(BOOT_OUT_DIR)/trusted/$$(OBM_TIM_1) $$(OUTPUT_DIR)/$$(private_product)/trusted
	$$(hide)cp $$(SRC_DIR)/$$(BOOT_OUT_DIR)/trusted/$$(OBM_TIM_DESC_1) $$(OUTPUT_DIR)/$$(private_product)/trusted
	$$(hide)cp $$(SRC_DIR)/$$(BOOT_OUT_DIR)/trusted/$$(OBM_DTIM_1) $$(OUTPUT_DIR)/$$(private_product)/trusted
	$$(hide)if [ -f $$(SRC_DIR)/$$(BOOT_OUT_DIR)/trusted/$$(OBM_DTIM_DESC_1) ]; then cp $$(SRC_DIR)/$$(BOOT_OUT_DIR)/trusted/$$(OBM_DTIM_DESC_1) $$(OUTPUT_DIR)/$$(private_product)/trusted; fi
	$$(hide)if [ -f $$(SRC_DIR)/$$(BOOT_OUT_DIR)/trusted/$$(OBM_DTIM_DESC_2) ]; then cp $$(SRC_DIR)/$$(BOOT_OUT_DIR)/trusted/$$(OBM_DTIM_DESC_2) $$(OUTPUT_DIR)/$$(private_product)/trusted; fi
	$$(hide)cp $$(SRC_DIR)/$$(BOOT_OUT_DIR)/trusted/$$(OBM_DTIM_KEY_1) $$(OUTPUT_DIR)/$$(private_product)/trusted
	$$(hide)cp $$(SRC_DIR)/$$(BOOT_OUT_DIR)/nontrusted/$$(UBOOT) $$(OUTPUT_DIR)/$$(private_product)/nontrusted
	$$(hide)cp $$(SRC_DIR)/$$(BOOT_OUT_DIR)/nontrusted/$$(OBM_NTLOADER_1) $$(OUTPUT_DIR)/$$(private_product)/nontrusted
	$$(hide)cp $$(SRC_DIR)/$$(BOOT_OUT_DIR)/nontrusted/$$(OBM_NTIM_1) $$(OUTPUT_DIR)/$$(private_product)/nontrusted
	$$(hide)cp $$(SRC_DIR)/$$(BOOT_OUT_DIR)/nontrusted/$$(OBM_NTIM_DESC_1) $$(OUTPUT_DIR)/$$(private_product)/nontrusted
	$$(hide)cp $$(SRC_DIR)/$$(BOOT_OUT_DIR)/nontrusted/$$(OBM_DNTIM_1) $$(OUTPUT_DIR)/$$(private_product)/nontrusted
	$$(hide)if [ -f $$(SRC_DIR)/$$(BOOT_OUT_DIR)/nontrusted/$$(OBM_DNTIM_DESC_1) ]; then cp $$(SRC_DIR)/$$(BOOT_OUT_DIR)/nontrusted/$$(OBM_DNTIM_DESC_1) $$(OUTPUT_DIR)/$$(private_product)/nontrusted; fi
	$$(hide)if [ -f $$(SRC_DIR)/$$(BOOT_OUT_DIR)/nontrusted/$$(OBM_DNTIM_DESC_2) ]; then cp $$(SRC_DIR)/$$(BOOT_OUT_DIR)/nontrusted/$$(OBM_DNTIM_DESC_2) $$(OUTPUT_DIR)/$$(private_product)/nontrusted; fi
	$$(log) "  done."
endef

define define-clean-uboot-obm
tw:=$$(subst :,  , $(1))
product:=$$(word 1, $$(tw))
device:=$$(word 2, $$(tw))

.PHONY:clean_uboot_obm_$$(product)
clean_uboot_obm_$$(product): private_product:=$$(product)
clean_uboot_obm_$$(product): private_device:=$$(device)
clean_uboot_obm_$$(product):
	$(log) "cleaning uboot and obm..."
	$(hide)cd $(SRC_DIR)/$(BOOT_SRC_DIR) && \
	. $$(ABS_TOP_DIR)/tools/apb $$(private_product) && \
	choosetype $$(DROID_TYPE) && choosevariant $$(DROID_VARIANT) && \
	make clean
	$(log) "    done."
endef
