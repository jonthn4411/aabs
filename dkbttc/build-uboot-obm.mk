#check if the required variables have been set.
$(call check-variables,BUILD_VARIANTS)
TEL_SRC_DIR:=kernel/out/telephony/

#$1:build variant
define define-build-uboot-obm
#format: <file name>:[m|o]:[md5]
#m:means mandatory
#o:means optional
#md5: need to generate md5 sum
#PUBLISHING_FILES_$(1)+=$(1)/NTIM_OBM_UBOOT.bin:m:md5
#PUBLISHING_FILES_$(1)+=$(1)/TTC_LINUX_NTOBM.bin:m:md5
PUBLISHING_FILES_$(1)+=$(1)/Arbel.bin:m:md5
PUBLISHING_FILES_$(1)+=$(1)/TTC1_M05_A0_AI_Flash.bin:m:md5
PUBLISHING_FILES_$(1)+=$(1)/u-boot.bin:m:md5
PUBLISHING_FILES_$(1)+=$(1)/ReliableData.bin:m:md5
PUBLISHING_FILES_$(1)+=$(1)/Arbel_DIAG.mdb:m:md5
PUBLISHING_FILES_$(1)+=$(1)/Arbel_NVM.mdb:m:md5
PUBLISHING_FILES_$(1)+=$(1)/ramdisk_no_gui.img:m:md5
PUBLISHING_FILES_$(1)+=$(1)/Software_Downloader.zip:m:md5

.PHONY:build_uboot_obm_$(1)
build_uboot_obm_$(1):
	$$(hide)cd $$(SRC_DIR)/boot && \
	make all
	$$(hide)mkdir -p $$(OUTPUT_DIR)/$(1)
	$$(log) "start to copy obm and CP image files"
	$$(hide)cp $$(SRC_DIR)/boot/out/* $$(OUTPUT_DIR)/$(1)
	$$(hide)cp $$(SRC_DIR)/$$(TEL_SRC_DIR)/Arbel.bin $$(OUTPUT_DIR)/$(1)
	$$(hide)cp $$(SRC_DIR)/$$(TEL_SRC_DIR)/Arbel_DIAG.mdb $$(OUTPUT_DIR)/$(1)
	$$(hide)cp $$(SRC_DIR)/$$(TEL_SRC_DIR)/Arbel_NVM.mdb $$(OUTPUT_DIR)/$(1)
	$$(hide)cp $$(SRC_DIR)/$$(TEL_SRC_DIR)/TTC1_M05_A0_AI_Flash.bin $$(OUTPUT_DIR)/$(1)
	$$(hide)cp $$(SRC_DIR)/$$(TEL_SRC_DIR)/ReliableData.bin $$(OUTPUT_DIR)/$(1)
	$$(hide)cp $$(SRC_DIR)/$$(TEL_SRC_DIR)/ramdisk_no_gui.img $$(OUTPUT_DIR)/$(1)
	$$(hide)cp $$(SRC_DIR)/$$(TEL_SRC_DIR)/Software_Downloader.zip $$(OUTPUT_DIR)/$(1)
	$$(log) "cp OBM and CP images  done."

endef

$(foreach bv, $(BUILD_VARIANTS), $(eval $(call define-build-uboot-obm,$(bv)) ) )

.PHONY:clean_uboot_obm
clean_uboot_obm:
	$(log) "cleaning and uboot..."
	$(hide)cd $(SRC_DIR)/boot && \
	make clean_uboot
	$(log) "  clean and uboot  done."


