#check if the required variables have been set.
$(call check-variables,BUILD_VARIANTS)
BOOT_SRC_DIR:=boot
BOOT_OUT_DIR:=$(BOOT_SRC_DIR)/out
UBOOT:=u-boot.bin
OBM_DESC_1:=ntim_mmp3_v7_mp_emmc_dis_uboot.txt
OBM_NTIM_1:=ntim_mmp3_v7_mp_emmc_dis_uboot.bin
OBM_DESC_2:=ntim_mmp3_v7_mp_emmc_pop_uboot.txt
OBM_NTIM_2:=ntim_mmp3_v7_mp_emmc_pop_uboot.bin
LOOP_BIN:=LoopSelf.bin
WTM_1:=wtm_400_MHz.bin

#$1:build variant
define define-build-uboot-obm
#format: <file name>:[m|o]:[md5]
#m:means mandatory
#o:means optional
#md5: need to generate md5 sum
PUBLISHING_FILES+=$(1)/$(UBOOT):m:md5
PUBLISHING_FILES_$(1)+=$(1)/emmc/$(OBM_NTIM_1):m:md5
PUBLISHING_FILES_$(1)+=$(1)/emmc/$(OBM_DESC_1):m:md5
PUBLISHING_FILES_$(1)+=$(1)/emmc/$(OBM_NTIM_2):m:md5
PUBLISHING_FILES_$(1)+=$(1)/emmc/$(OBM_DESC_2):m:md5
PUBLISHING_FILES_$(1)+=$(1)/emmc/$(WTM_1):m:md5
PUBLISHING_FILES_$(1)+=$(1)/emmc/$(LOOP_BIN):m:md5



.PHONY:build_uboot_obm_$(1)
build_uboot_obm_$(1):
	$$(log) "starting($(1)) to build uboot and obm"
	$$(hide)cd $$(SRC_DIR)/$$(BOOT_SRC_DIR) && \
	make all
	$$(hide)mkdir -p $$(OUTPUT_DIR)/$(1)
	$$(hide)mkdir -p $$(OUTPUT_DIR)/$(1)/emmc

	$$(log) "start to copy uboot and obm files"
	$$(hide)cp $$(SRC_DIR)/$$(BOOT_OUT_DIR)/u-boot.bin $$(OUTPUT_DIR)/$(1)
	$$(hide)cp $$(SRC_DIR)/$$(BOOT_OUT_DIR)/emmc/$$(OBM_NTIM_1) $$(OUTPUT_DIR)/$(1)/emmc
	$$(hide)cp $$(SRC_DIR)/$$(BOOT_OUT_DIR)/emmc/$$(OBM_DESC_1) $$(OUTPUT_DIR)/$(1)/emmc
	$$(hide)cp $$(SRC_DIR)/$$(BOOT_OUT_DIR)/emmc/$$(OBM_NTIM_2) $$(OUTPUT_DIR)/$(1)/emmc
	$$(hide)cp $$(SRC_DIR)/$$(BOOT_OUT_DIR)/emmc/$$(OBM_DESC_2) $$(OUTPUT_DIR)/$(1)/emmc
	$$(hide)cp $$(SRC_DIR)/$$(BOOT_OUT_DIR)/emmc/$$(WTM_1) $$(OUTPUT_DIR)/$(1)/emmc
	$$(hide)cp $$(SRC_DIR)/$$(BOOT_OUT_DIR)/emmc/$$(LOOP_BIN) $$(OUTPUT_DIR)/$(1)/emmc
	$$(log) "  done."

endef

$(foreach bv, $(BUILD_VARIANTS), $(eval $(call define-build-uboot-obm,$(bv)) ) )

.PHONY:clean_uboot_obm
clean_uboot_obm:
	$(log) "cleaning uboot and obm..."
	$(hide)cd $(SRC_DIR)/$(BOOT_SRC_DIR) && \
	make clean
	$(log) "    done."




