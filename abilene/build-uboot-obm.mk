#check if the required variables have been set.

$(call check-variables,BUILD_VARIANTS)
BOOT_SRC_DIR:=boot
BOOT_OUT_DIR:=$(BOOT_SRC_DIR)/out
BOOT_OUT_CM_DIR:=$(BOOT_OUT_DIR)/CM
BOOT_OUT_NOR_DIR:=$(BOOT_OUT_DIR)/NORMAL


#$1:build variant
define define-build-uboot-obm
#format: <file name>:[m|o]:[md5]
#m:means mandatory
#o:means optional
#md5: need to generate md5 sum
PUBLISHING_FILES_$(1)+=$(1)/emmc/u-boot.bin:m:md5
PUBLISHING_FILES_$(1)+=$(1)/emmc/Wtm_rel_mmp3.bin:m:md5
PUBLISHING_FILES_$(1)+=$(1)/emmc/ntim.bin.tgz:m:md5
PUBLISHING_FILES_$(1)+=$(1)/emmc_cm/u-boot.bin:m:md5
PUBLISHING_FILES_$(1)+=$(1)/emmc_cm/Wtm_rel_mmp3.bin:m:md5
PUBLISHING_FILES_$(1)+=$(1)/emmc_cm/coremorphall.bin:m:md5
PUBLISHING_FILES_$(1)+=$(1)/emmc_cm/ntim.bin.tgz:m:md5

.PHONY:build_uboot_obm_$(1)
build_uboot_obm_$(1):
	$$(log) "starting($(1)) to build uboot and obm"
	$$(hide)cd $$(SRC_DIR)/$$(BOOT_SRC_DIR) && \
	make all
	$$(hide)mkdir -p $$(OUTPUT_DIR)/$(1)
	$$(hide)mkdir -p $$(OUTPUT_DIR)/$(1)/emmc
	$$(hide)mkdir -p $$(OUTPUT_DIR)/$(1)/emmc/ntim
	$$(hide)mkdir -p $$(OUTPUT_DIR)/$(1)/emmc_cm
	$$(hide)mkdir -p $$(OUTPUT_DIR)/$(1)/emmc_cm/ntim

	$$(log) "start to copy uboot and obm files"
	$$(hide)cp $$(SRC_DIR)/$$(BOOT_OUT_NOR_DIR)/u-boot.bin $$(OUTPUT_DIR)/$(1)/emmc
	$$(hide)cp $$(SRC_DIR)/$$(BOOT_OUT_NOR_DIR)/Wtm_rel_mmp3.bin $$(OUTPUT_DIR)/$(1)/emmc
	$$(hide)cp $$(SRC_DIR)/$$(BOOT_OUT_NOR_DIR)/ntim/* $$(OUTPUT_DIR)/$(1)/emmc/ntim/
	$$(hide)cd $$(OUTPUT_DIR)/$(1)/emmc/ && tar zcvf ntim.bin.tgz ntim
	$$(hide)cp $$(SRC_DIR)/$$(BOOT_OUT_CM_DIR)/u-boot.bin $$(OUTPUT_DIR)/$(1)/emmc_cm
	$$(hide)cp $$(SRC_DIR)/$$(BOOT_OUT_CM_DIR)/Wtm_rel_mmp3.bin $$(OUTPUT_DIR)/$(1)/emmc_cm
	$$(hide)cp $$(SRC_DIR)/$$(BOOT_OUT_CM_DIR)/coremorphall.bin $$(OUTPUT_DIR)/$(1)/emmc_cm
	$$(hide)cp $$(SRC_DIR)/$$(BOOT_OUT_CM_DIR)/ntim/* $$(OUTPUT_DIR)/$(1)/emmc_cm/ntim/
	$$(hide)cd $$(OUTPUT_DIR)/$(1)/emmc_cm/ && tar zcvf ntim.bin.tgz ntim
	$$(log) "    done."

endef

$(foreach bv, $(BUILD_VARIANTS), $(eval $(call define-build-uboot-obm,$(bv)) ) )

.PHONY:clean_uboot_obm
clean_uboot_obm:
	$(log) "cleaning uboot and obm..."
	$(hide)cd $(SRC_DIR)/$(BOOT_SRC_DIR) && \
	make clean
	$(log) "    done."




