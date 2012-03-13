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
PUBLISHING_FILES_$(1)+=$(1)/nontrusted/u-boot.bin:m:md5
PUBLISHING_FILES_$(1)+=$(1)/nontrusted/Wtm_rel_mmp3.bin:m:md5
PUBLISHING_FILES_$(1)+=$(1)/nontrusted/ntim.bin.tgz:m:md5
PUBLISHING_FILES_$(1)+=$(1)/trusted/u-boot.bin:m:md5
PUBLISHING_FILES_$(1)+=$(1)/trusted/Wtm_rel_mmp3.bin:m:md5
PUBLISHING_FILES_$(1)+=$(1)/trusted/coremorphall.bin:m:md5
PUBLISHING_FILES_$(1)+=$(1)/trusted/ntim.bin.tgz:m:md5

.PHONY:build_uboot_obm_$(1)
build_uboot_obm_$(1):
	$$(log) "starting($(1)) to build uboot and obm"
	$$(hide)cd $$(SRC_DIR)/$$(BOOT_SRC_DIR) && \
	make all
	$$(hide)mkdir -p $$(OUTPUT_DIR)/$(1)
	$$(hide)mkdir -p $$(OUTPUT_DIR)/$(1)/nontrusted
	$$(hide)mkdir -p $$(OUTPUT_DIR)/$(1)/nontrusted/ntim
	$$(hide)mkdir -p $$(OUTPUT_DIR)/$(1)/trusted
	$$(hide)mkdir -p $$(OUTPUT_DIR)/$(1)/trusted/ntim

	$$(log) "start to copy uboot and obm files"
	$$(hide)cp $$(SRC_DIR)/$$(BOOT_OUT_NOR_DIR)/u-boot.bin $$(OUTPUT_DIR)/$(1)/nontrusted
	$$(hide)cp $$(SRC_DIR)/$$(BOOT_OUT_NOR_DIR)/Wtm_rel_mmp3.bin $$(OUTPUT_DIR)/$(1)/nontrusted
	$$(hide)cp -rf $$(SRC_DIR)/$$(BOOT_OUT_NOR_DIR)/ntim/ $$(OUTPUT_DIR)/$(1)/nontrusted/
	$$(hide)cd $$(OUTPUT_DIR)/$(1)/nontrusted/ && tar zcvf ntim.bin.tgz ntim
	$$(hide)cp $$(SRC_DIR)/$$(BOOT_OUT_CM_DIR)/u-boot.bin $$(OUTPUT_DIR)/$(1)/trusted
	$$(hide)cp $$(SRC_DIR)/$$(BOOT_OUT_CM_DIR)/Wtm_rel_mmp3.bin $$(OUTPUT_DIR)/$(1)/trusted
	$$(hide)cp $$(SRC_DIR)/$$(BOOT_OUT_CM_DIR)/coremorphall.bin $$(OUTPUT_DIR)/$(1)/trusted
	$$(hide)cp -rf $$(SRC_DIR)/$$(BOOT_OUT_CM_DIR)/ntim/ $$(OUTPUT_DIR)/$(1)/trusted/
	$$(hide)cd $$(OUTPUT_DIR)/$(1)/trusted/ && tar zcvf ntim.bin.tgz ntim
	$$(log) "    done."

endef

$(foreach bv, $(BUILD_VARIANTS), $(eval $(call define-build-uboot-obm,$(bv)) ) )

.PHONY:clean_uboot_obm
clean_uboot_obm:
	$(log) "cleaning uboot and obm..."
	$(hide)cd $(SRC_DIR)/$(BOOT_SRC_DIR) && \
	make clean
	$(log) "    done."




