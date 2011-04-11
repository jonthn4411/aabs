#check if the required variables have been set.
$(call check-variables,BUILD_VARIANTS)
TEL_SRC_DIR:=kernel/out/telephony/

DKBTD_UBOOT:=u-boot.bin
DKBTD_UBOOT_PXA921:=u-boot_emmc.bin
DKBTD_CP1:=Arbel_DKB_SKWS.bin
DKBTD_CP2:=Arbel_DKB_SKWS_DIAG.mdb
DKBTD_CP3:=Arbel_DKB_SKWS_NVM.mdb
DKBTD_CP4:=TTD_M06_AI_A0_Flash.bin
DKBTD_CP5:=TTD_M06_AI_A1_Flash.bin
DKBTD_IMEI:=ReliableData.bin
DKBTD_SWD:=Software_Downloader.zip
#DKBTD_NO_GUI_RAMDISK:=ramdisk_no_gui.img

#$1:build variant
define define-copy-obm-cp-image
#format: <file name>:[m|o]:[md5]
#m:means mandatory
#o:means optional
#md5: need to generate md5 sum
#PUBLISHING_FILES_$(1)+=$(1)/NTIM_OBM_UBOOT.bin:m:md5
#PUBLISHING_FILES_$(1)+=$(1)/TTC_LINUX_NTOBM.bin:m:md5
PUBLISHING_FILES_$(1)+=$(1)/$(DKBTD_UBOOT):m:md5
PUBLISHING_FILES_$(1)+=$(1)/$(DKBTD_UBOOT_PXA921):m:md5
PUBLISHING_FILES_$(1)+=$(1)/$(DKBTD_CP1):m:md5
PUBLISHING_FILES_$(1)+=$(1)/$(DKBTD_CP2):m:md5
PUBLISHING_FILES_$(1)+=$(1)/$(DKBTD_CP3):m:md5
PUBLISHING_FILES_$(1)+=$(1)/$(DKBTD_CP4):m:md5
PUBLISHING_FILES_$(1)+=$(1)/$(DKBTD_CP5):m:md5
PUBLISHING_FILES_$(1)+=$(1)/$(DKBTD_IMEI):m:md5
PUBLISHING_FILES_$(1)+=$(1)/$(DKBTD_SWD):m:md5
#PUBLISHING_FILES_$(1)+=$(1)/$(DKBTD_NO_GUI_RAMDISK):m:md5

.PHONY:copy_obm_cp_image_$(1)
copy_obm_cp_image_$(1):
	$$(hide)mkdir -p $$(OUTPUT_DIR)/$(1)
	$$(log) "start to copy obm and CP image files"
	$$(hide)cp -r $$(SRC_DIR)/boot/out/* $$(OUTPUT_DIR)/$(1)
	$$(hide)cp $$(SRC_DIR)/$$(TEL_SRC_DIR)/$(DKBTD_CP1) $$(OUTPUT_DIR)/$(1)
	$$(hide)cp $$(SRC_DIR)/$$(TEL_SRC_DIR)/$(DKBTD_CP2) $$(OUTPUT_DIR)/$(1)
	$$(hide)cp $$(SRC_DIR)/$$(TEL_SRC_DIR)/$(DKBTD_CP3) $$(OUTPUT_DIR)/$(1)
	$$(hide)cp $$(SRC_DIR)/$$(TEL_SRC_DIR)/$(DKBTD_CP4) $$(OUTPUT_DIR)/$(1)
	$$(hide)cp $$(SRC_DIR)/$$(TEL_SRC_DIR)/$(DKBTD_CP5) $$(OUTPUT_DIR)/$(1)
	$$(hide)cp $$(SRC_DIR)/$$(TEL_SRC_DIR)/$(DKBTD_IMEI) $$(OUTPUT_DIR)/$(1)
#	$$(hide)cp $$(SRC_DIR)/$$(TEL_SRC_DIR)/$(DKBTD_NO_GUI_RAMDISK) $$(OUTPUT_DIR)/$(1)
	$$(log) "cp OBM and CP images  done."

endef

$(foreach bv, $(BUILD_VARIANTS), $(eval $(call define-copy-obm-cp-image,$(bv)) ) )


