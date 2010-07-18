#check if the required variables have been set.
$(call check-variables,BUILD_VARIANTS)
TEL_SRC_DIR:=kernel/out/telephony/

DKBTTC_UBOOT:=u-boot.bin
DKBTTC_CP1:=Arbel_DIGRF3.bin
DKBTTC_CP2:=Arbel_DIGRF3_DIAG.mdb
DKBTTC_CP3:=Arbel_DIGRF3_NVM.mdb
DKBTTC_CP4:=TTC1_M05_AI_A1_Flash.bin
DKBTTC_IMEI:=ReliableData.bin
DKBTTC_SWD:=Software_Downloader.zip
DKBTTC_NO_GUI_RAMDISK:=ramdisk_no_gui.img

#$1:build variant
define define-build-uboot-obm
#format: <file name>:[m|o]:[md5]
#m:means mandatory
#o:means optional
#md5: need to generate md5 sum
#PUBLISHING_FILES_$(1)+=$(1)/NTIM_OBM_UBOOT.bin:m:md5
#PUBLISHING_FILES_$(1)+=$(1)/TTC_LINUX_NTOBM.bin:m:md5
PUBLISHING_FILES_$(1)+=$(1)/$(DKBTTC_UBOOT):m:md5
PUBLISHING_FILES_$(1)+=$(1)/$(DKBTTC_CP1):m:md5
PUBLISHING_FILES_$(1)+=$(1)/$(DKBTTC_CP2):m:md5
PUBLISHING_FILES_$(1)+=$(1)/$(DKBTTC_CP3):m:md5
PUBLISHING_FILES_$(1)+=$(1)/$(DKBTTC_CP4):m:md5
PUBLISHING_FILES_$(1)+=$(1)/$(DKBTTC_IMEI):m:md5
PUBLISHING_FILES_$(1)+=$(1)/$(DKBTTC_SWD):m:md5
PUBLISHING_FILES_$(1)+=$(1)/$(DKBTTC_NO_GUI_RAMDISK):m:md5

.PHONY:build_uboot_obm_$(1)
build_uboot_obm_$(1):
	$$(hide)cd $$(SRC_DIR)/boot && \
	make all
	$$(hide)mkdir -p $$(OUTPUT_DIR)/$(1)
	$$(log) "start to copy obm and CP image files"
	$$(hide)cp -r $$(SRC_DIR)/boot/out/* $$(OUTPUT_DIR)/$(1)
	$$(hide)cp $$(SRC_DIR)/$$(TEL_SRC_DIR)/$(DKBTTC_CP1) $$(OUTPUT_DIR)/$(1)
	$$(hide)cp $$(SRC_DIR)/$$(TEL_SRC_DIR)/$(DKBTTC_CP2) $$(OUTPUT_DIR)/$(1)
	$$(hide)cp $$(SRC_DIR)/$$(TEL_SRC_DIR)/$(DKBTTC_CP3) $$(OUTPUT_DIR)/$(1)
	$$(hide)cp $$(SRC_DIR)/$$(TEL_SRC_DIR)/$(DKBTTC_CP4) $$(OUTPUT_DIR)/$(1)
	$$(hide)cp $$(SRC_DIR)/$$(TEL_SRC_DIR)/$(DKBTTC_IMEI) $$(OUTPUT_DIR)/$(1)
	$$(hide)cp $$(SRC_DIR)/$$(TEL_SRC_DIR)/$(DKBTTC_NO_GUI_RAMDISK) $$(OUTPUT_DIR)/$(1)
	$$(log) "cp OBM and CP images  done."

endef

$(foreach bv, $(BUILD_VARIANTS), $(eval $(call define-build-uboot-obm,$(bv)) ) )

.PHONY:clean_uboot_obm
clean_uboot_obm:
	$(log) "cleaning and uboot..."
	$(hide)cd $(SRC_DIR)/boot && \
	make clean_uboot
	$(log) "  clean and uboot  done."


