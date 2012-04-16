#check if the required variables have been set.
$(call check-variables,BUILD_VARIANTS)
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
#format: <file name>:[m|o]:[md5]
#m:means mandatory
#o:means optional
#md5: need to generate md5 sum
PUBLISHING_FILES_$(1)+=$(1)/trusted/$(UBOOT):m:md5
PUBLISHING_FILES_$(1)+=$(1)/trusted/$(OBM_TLOADER_1):m:md5
PUBLISHING_FILES_$(1)+=$(1)/trusted/$(OBM_TIM_1):m:md5
PUBLISHING_FILES_$(1)+=$(1)/trusted/$(OBM_TIM_DESC_1):m:md5
PUBLISHING_FILES_$(1)+=$(1)/trusted/$(OBM_DTIM_1):m:md5
PUBLISHING_FILES_$(1)+=$(1)/trusted/$(OBM_DTIM_DESC_1):o:md5
PUBLISHING_FILES_$(1)+=$(1)/trusted/$(OBM_DTIM_DESC_2):o:md5
PUBLISHING_FILES_$(1)+=$(1)/trusted/$(OBM_DTIM_KEY_1):m:md5
PUBLISHING_FILES_$(1)+=$(1)/nontrusted/$(UBOOT):m:md5
PUBLISHING_FILES_$(1)+=$(1)/nontrusted/$(OBM_NTLOADER_1):m:md5
PUBLISHING_FILES_$(1)+=$(1)/nontrusted/$(OBM_NTIM_1):m:md5
PUBLISHING_FILES_$(1)+=$(1)/nontrusted/$(OBM_NTIM_DESC_1):m:md5
PUBLISHING_FILES_$(1)+=$(1)/nontrusted/$(OBM_DNTIM_1):m:md5
PUBLISHING_FILES_$(1)+=$(1)/nontrusted/$(OBM_DNTIM_DESC_1):o:md5
PUBLISHING_FILES_$(1)+=$(1)/nontrusted/$(OBM_DNTIM_DESC_2):o:md5
PUBLISHING_FILES_$(1)+=$(1)/$(WTM_1):m:md5

.PHONY:build_uboot_obm_$(1)
build_uboot_obm_$(1):
	$$(log) "starting($(1)) to build uboot and obm"
	$$(hide)cd $$(SRC_DIR) && \
	. $$(TOP_DIR)/tools/apb $$(DROID_PRODUCT) && \
	choosetype $$(DROID_TYPE) && choosevariant $$(DROID_VARIANT) && \
	cd $$(BOOT_SRC_DIR) && \
	make all
	$$(hide)mkdir -p $$(OUTPUT_DIR)/$(1)
	$$(hide)mkdir -p $$(OUTPUT_DIR)/$(1)/trusted
	$$(hide)mkdir -p $$(OUTPUT_DIR)/$(1)/nontrusted

	$$(log) "start to copy uboot and obm files"
	$$(hide)cp $$(SRC_DIR)/$$(BOOT_OUT_DIR)/$$(WTM_1) $$(OUTPUT_DIR)/$(1)
	$$(hide)cp $$(SRC_DIR)/$$(BOOT_OUT_DIR)/trusted/$$(UBOOT) $$(OUTPUT_DIR)/$(1)/trusted
	$$(hide)cp $$(SRC_DIR)/$$(BOOT_OUT_DIR)/trusted/$$(OBM_TLOADER_1) $$(OUTPUT_DIR)/$(1)/trusted
	$$(hide)cp $$(SRC_DIR)/$$(BOOT_OUT_DIR)/trusted/$$(OBM_TIM_1) $$(OUTPUT_DIR)/$(1)/trusted
	$$(hide)cp $$(SRC_DIR)/$$(BOOT_OUT_DIR)/trusted/$$(OBM_TIM_DESC_1) $$(OUTPUT_DIR)/$(1)/trusted
	$$(hide)cp $$(SRC_DIR)/$$(BOOT_OUT_DIR)/trusted/$$(OBM_DTIM_1) $$(OUTPUT_DIR)/$(1)/trusted
	$$(hide)if [ -f $$(SRC_DIR)/$$(BOOT_OUT_DIR)/trusted/$$(OBM_DTIM_DESC_1) ]; then cp $$(SRC_DIR)/$$(BOOT_OUT_DIR)/trusted/$$(OBM_DTIM_DESC_1) $$(OUTPUT_DIR)/$(1)/trusted; fi
	$$(hide)if [ -f $$(SRC_DIR)/$$(BOOT_OUT_DIR)/trusted/$$(OBM_DTIM_DESC_2) ]; then cp $$(SRC_DIR)/$$(BOOT_OUT_DIR)/trusted/$$(OBM_DTIM_DESC_2) $$(OUTPUT_DIR)/$(1)/trusted; fi
	$$(hide)cp $$(SRC_DIR)/$$(BOOT_OUT_DIR)/trusted/$$(OBM_DTIM_KEY_1) $$(OUTPUT_DIR)/$(1)/trusted
	$$(hide)cp $$(SRC_DIR)/$$(BOOT_OUT_DIR)/nontrusted/$$(UBOOT) $$(OUTPUT_DIR)/$(1)/nontrusted
	$$(hide)cp $$(SRC_DIR)/$$(BOOT_OUT_DIR)/nontrusted/$$(OBM_NTLOADER_1) $$(OUTPUT_DIR)/$(1)/nontrusted
	$$(hide)cp $$(SRC_DIR)/$$(BOOT_OUT_DIR)/nontrusted/$$(OBM_NTIM_1) $$(OUTPUT_DIR)/$(1)/nontrusted
	$$(hide)cp $$(SRC_DIR)/$$(BOOT_OUT_DIR)/nontrusted/$$(OBM_NTIM_DESC_1) $$(OUTPUT_DIR)/$(1)/nontrusted
	$$(hide)cp $$(SRC_DIR)/$$(BOOT_OUT_DIR)/nontrusted/$$(OBM_DNTIM_1) $$(OUTPUT_DIR)/$(1)/nontrusted
	$$(hide)if [ -f $$(SRC_DIR)/$$(BOOT_OUT_DIR)/nontrusted/$$(OBM_DNTIM_DESC_1) ]; then cp $$(SRC_DIR)/$$(BOOT_OUT_DIR)/nontrusted/$$(OBM_DNTIM_DESC_1) $$(OUTPUT_DIR)/$(1)/nontrusted; fi
	$$(hide)if [ -f $$(SRC_DIR)/$$(BOOT_OUT_DIR)/nontrusted/$$(OBM_DNTIM_DESC_2) ]; then cp $$(SRC_DIR)/$$(BOOT_OUT_DIR)/nontrusted/$$(OBM_DNTIM_DESC_2) $$(OUTPUT_DIR)/$(1)/nontrusted; fi
	$$(log) "  done."
endef

.PHONY:clean_uboot_obm
clean_uboot_obm:
	$(log) "cleaning uboot and obm..."
	$(hide)cd $(SRC_DIR)/$(BOOT_SRC_DIR) && \
	make clean
	$(log) "    done."
