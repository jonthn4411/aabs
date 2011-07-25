#check if the required variables have been set.
$(call check-variables,BUILD_VARIANTS)
BOOT_SRC_DIR:=boot
BOOT_OUT_DIR:=$(BOOT_SRC_DIR)/out
UBOOT:=u-boot.bin
OBM_DESC_1:=ntim_mmp3_v7_mp_emmc_dis_uboot.txt
OBM_NTIM_1:=ntim_mmp3_v7_mp_emmc_dis_uboot.bin
OBM_DESC_2:=ntim_mmp3_v7_mp_emmc_pop_uboot.txt
OBM_NTIM_2:=ntim_mmp3_v7_mp_emmc_pop_uboot.bin
OBM_DESC_3:=ntim_mmp3_v7_mp_emmc_dis_uboot_800.txt
OBM_NTIM_3:=ntim_mmp3_v7_mp_emmc_dis_uboot_800.bin
OBM_DESC_4:=ntim_mmp3_v7_mp_emmc_dis_uboot_1000.txt
OBM_NTIM_4:=ntim_mmp3_v7_mp_emmc_dis_uboot_1000.bin
OBM_DESC_5:=ntim_mmp3_v7_mp_emmc_pop_uboot_800.txt
OBM_NTIM_5:=ntim_mmp3_v7_mp_emmc_pop_uboot_800.bin
OBM_DESC_6:=ntim_mmp3_v7_mp_emmc_pop_uboot_1000.txt
OBM_NTIM_6:=ntim_mmp3_v7_mp_emmc_pop_uboot_1000.bin
OBM_DESC_7:=ntim-mmp3-yellowstone-dis-800.txt
OBM_NTIM_7:=ntim-mmp3-yellowstone-dis-800.bin
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
PUBLISHING_FILES_$(1)+=$(1)/emmc/$(OBM_NTIM_3):m:md5
PUBLISHING_FILES_$(1)+=$(1)/emmc/$(OBM_DESC_3):m:md5
PUBLISHING_FILES_$(1)+=$(1)/emmc/$(OBM_NTIM_4):m:md5
PUBLISHING_FILES_$(1)+=$(1)/emmc/$(OBM_DESC_4):m:md5
PUBLISHING_FILES_$(1)+=$(1)/emmc/$(OBM_NTIM_5):m:md5
PUBLISHING_FILES_$(1)+=$(1)/emmc/$(OBM_DESC_5):m:md5
PUBLISHING_FILES_$(1)+=$(1)/emmc/$(OBM_NTIM_6):m:md5
PUBLISHING_FILES_$(1)+=$(1)/emmc/$(OBM_DESC_6):m:md5
PUBLISHING_FILES_$(1)+=$(1)/emmc/$(OBM_NTIM_7):m:md5
PUBLISHING_FILES_$(1)+=$(1)/emmc/$(OBM_DESC_7):m:md5
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
	$$(hide)cp $$(SRC_DIR)/$$(BOOT_OUT_DIR)/emmc/$$(OBM_NTIM_3) $$(OUTPUT_DIR)/$(1)/emmc
	$$(hide)cp $$(SRC_DIR)/$$(BOOT_OUT_DIR)/emmc/$$(OBM_DESC_3) $$(OUTPUT_DIR)/$(1)/emmc
	$$(hide)cp $$(SRC_DIR)/$$(BOOT_OUT_DIR)/emmc/$$(OBM_NTIM_4) $$(OUTPUT_DIR)/$(1)/emmc
	$$(hide)cp $$(SRC_DIR)/$$(BOOT_OUT_DIR)/emmc/$$(OBM_DESC_4) $$(OUTPUT_DIR)/$(1)/emmc
	$$(hide)cp $$(SRC_DIR)/$$(BOOT_OUT_DIR)/emmc/$$(OBM_NTIM_5) $$(OUTPUT_DIR)/$(1)/emmc
	$$(hide)cp $$(SRC_DIR)/$$(BOOT_OUT_DIR)/emmc/$$(OBM_DESC_5) $$(OUTPUT_DIR)/$(1)/emmc
	$$(hide)cp $$(SRC_DIR)/$$(BOOT_OUT_DIR)/emmc/$$(OBM_NTIM_6) $$(OUTPUT_DIR)/$(1)/emmc
	$$(hide)cp $$(SRC_DIR)/$$(BOOT_OUT_DIR)/emmc/$$(OBM_DESC_6) $$(OUTPUT_DIR)/$(1)/emmc
	$$(hide)cp $$(SRC_DIR)/$$(BOOT_OUT_DIR)/emmc/$$(OBM_NTIM_7) $$(OUTPUT_DIR)/$(1)/emmc
	$$(hide)cp $$(SRC_DIR)/$$(BOOT_OUT_DIR)/emmc/$$(OBM_DESC_7) $$(OUTPUT_DIR)/$(1)/emmc
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




