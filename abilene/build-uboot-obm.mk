#check if the required variables have been set.

$(call check-variables,BUILD_VARIANTS)
BOOT_SRC_DIR:=boot
BOOT_OUT_DIR:=$(BOOT_SRC_DIR)/out
BOOT_OUT_CM_DIR:=$(BOOT_OUT_DIR)/CM
UBOOT:=u-boot.bin
UBOOT_CM:=u-boot_cm.bin
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
OBM_DESC_8:=ntim_abex_dis-797-797-399-399-532-532-399-200__3_2_sm_533_1200mv.txt
OBM_NTIM_8:=ntim_abex_dis-797-797-399-399-532-532-399-200__3_2_sm_533_1200mv.bin
OBM_DESC_9:=ntim_abex_dis-797-797-399-399-532-532-399-200__3_2_sm_533_1225mv.txt
OBM_NTIM_9:=ntim_abex_dis-797-797-399-399-532-532-399-200__3_2_sm_533_1225mv.bin
WTM_BIN:=Wtm_rel_mmp3.bin
CM_BIN:=coremorphall.bin

#$1:build variant
define define-build-uboot-obm
#format: <file name>:[m|o]:[md5]
#m:means mandatory
#o:means optional
#md5: need to generate md5 sum
PUBLISHING_FILES_$(1)+=$(1)/emmc/$(UBOOT):m:md5
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
PUBLISHING_FILES_$(1)+=$(1)/emmc/$(WTM_BIN):m:md5
PUBLISHING_FILES_$(1)+=$(1)/emmc_cm/$(OBM_NTIM_8):m:md5
PUBLISHING_FILES_$(1)+=$(1)/emmc_cm/$(OBM_DESC_8):m:md5
PUBLISHING_FILES_$(1)+=$(1)/emmc_cm/$(OBM_NTIM_9):m:md5
PUBLISHING_FILES_$(1)+=$(1)/emmc_cm/$(OBM_DESC_9):m:md5
PUBLISHING_FILES_$(1)+=$(1)/emmc_cm/$(WTM_BIN):m:md5
PUBLISHING_FILES_$(1)+=$(1)/emmc_cm/$(CM_BIN):m:md5
PUBLISHING_FILES_$(1)+=$(1)/emmc_cm/$(UBOOT_CM):m:md5


.PHONY:build_uboot_obm_$(1)
build_uboot_obm_$(1):
	$$(log) "starting($(1)) to build uboot and obm"
	$$(hide)cd $$(SRC_DIR)/$$(BOOT_SRC_DIR) && \
	make all
	$$(hide)mkdir -p $$(OUTPUT_DIR)/$(1)
	$$(hide)mkdir -p $$(OUTPUT_DIR)/$(1)/emmc
	$$(hide)mkdir -p $$(OUTPUT_DIR)/$(1)/emmc_cm

	$$(log) "start to copy uboot and obm files"
	$$(hide)cp $$(SRC_DIR)/$$(BOOT_OUT_DIR)/u-boot.bin $$(OUTPUT_DIR)/$(1)/emmc
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
	$$(hide)cp $$(SRC_DIR)/$$(BOOT_OUT_DIR)/emmc/$$(WTM_BIN) $$(OUTPUT_DIR)/$(1)/emmc
	$$(hide)cp $$(SRC_DIR)/$$(BOOT_OUT_CM_DIR)/emmc/$$(OBM_NTIM_8) $$(OUTPUT_DIR)/$(1)/emmc_cm
	$$(hide)cp $$(SRC_DIR)/$$(BOOT_OUT_CM_DIR)/emmc/$$(OBM_DESC_8) $$(OUTPUT_DIR)/$(1)/emmc_cm
	$$(hide)cp $$(SRC_DIR)/$$(BOOT_OUT_CM_DIR)/emmc/$$(OBM_NTIM_9) $$(OUTPUT_DIR)/$(1)/emmc_cm
	$$(hide)cp $$(SRC_DIR)/$$(BOOT_OUT_CM_DIR)/emmc/$$(OBM_DESC_9) $$(OUTPUT_DIR)/$(1)/emmc_cm
	$$(hide)cp $$(SRC_DIR)/$$(BOOT_OUT_CM_DIR)/emmc/$$(WTM_BIN) $$(OUTPUT_DIR)/$(1)/emmc_cm
	$$(hide)cp $$(SRC_DIR)/$$(BOOT_OUT_CM_DIR)/emmc/$$(CM_BIN) $$(OUTPUT_DIR)/$(1)/emmc_cm
	$$(hide)cp $$(SRC_DIR)/$$(BOOT_OUT_CM_DIR)/emmc/$$(UBOOT_CM) $$(OUTPUT_DIR)/$(1)/emmc_cm
	$$(log) "  done."

endef

$(foreach bv, $(BUILD_VARIANTS), $(eval $(call define-build-uboot-obm,$(bv)) ) )

.PHONY:clean_uboot_obm
clean_uboot_obm:
	$(log) "cleaning uboot and obm..."
	$(hide)cd $(SRC_DIR)/$(BOOT_SRC_DIR) && \
	make clean
	$(log) "    done."




