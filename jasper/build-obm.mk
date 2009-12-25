#check if the required variables have been set.
$(call check-variables,OBM_SRC_DIR BUILD_VARIANTS)

OBM_NTIM_1:=ntim_a0_avengers-a_1.6F_256mb_400mhz_mode3_pm_slc.bin
OBM_NTIM_2:=ntim_a0_avengers-a_1.6F_256mb_400mhz_mode3_pm_spi.bin
OBM_DESC_1:=desc_a0_avengers-a_1.6F_256mb_400mhz_mode3_pm_slc.txt
OBM_DESC_2:=desc_a0_avengers-a_1.6F_256mb_400mhz_mode3_pm_spi.txt

OBM_NTLOADER_1:=ASPN_NTLOADER_avengers-a_slc.bin
OBM_NTLOADER_2:=ASPN_NTLOADER_spi.bin

OBM_BIN_DIR:=binaries/BootLoader
#$1:build variant
define define-build-obm

#format: <file name>:[m|o]:[md5]
#m:means mandatory
#o:means optional
#md5: need to generate md5 sum
PUBLISHING_FILES_$(1)+=$(1)/$(OBM_NTLOADER_1):m:md5
PUBLISHING_FILES_$(1)+=$(1)/$(OBM_NTLOADER_2):m:md5
PUBLISHING_FILES_$(1)+=$(1)/$(OBM_NTIM_1):m:md5
PUBLISHING_FILES_$(1)+=$(1)/$(OBM_NTIM_2):m:md5
PUBLISHING_FILES_$(1)+=$(1)/$(OBM_DESC_1):m:md5
PUBLISHING_FILES_$(1)+=$(1)/$(OBM_DESC_2):m:md5

.PHONY:build_obm_$(1)
build_obm_$(1):
	$$(log) "start to copy obm files"
	$$(hide)mkdir -p $$(OUTPUT_DIR)/$(1)
	$$(hide)cp $$(SRC_DIR)/$$(OBM_SRC_DIR)/$$(OBM_BIN_DIR)/$$(OBM_NTLOADER_1) $$(OUTPUT_DIR)/$(1)
	$$(hide)cp $$(SRC_DIR)/$$(OBM_SRC_DIR)/$$(OBM_BIN_DIR)/$$(OBM_NTLOADER_2) $$(OUTPUT_DIR)/$(1)
	$$(hide)cp $$(SRC_DIR)/$$(OBM_SRC_DIR)/$$(OBM_BIN_DIR)/$$(OBM_NTIM_1) $$(OUTPUT_DIR)/$(1)
	$$(hide)cp $$(SRC_DIR)/$$(OBM_SRC_DIR)/$$(OBM_BIN_DIR)/$$(OBM_NTIM_2) $$(OUTPUT_DIR)/$(1)
	$$(hide)cp $$(SRC_DIR)/$$(OBM_SRC_DIR)/$$(OBM_BIN_DIR)/$$(OBM_DESC_1) $$(OUTPUT_DIR)/$(1)
	$$(hide)cp $$(SRC_DIR)/$$(OBM_SRC_DIR)/$$(OBM_BIN_DIR)/$$(OBM_DESC_2) $$(OUTPUT_DIR)/$(1)
	$$(log) "  done."
endef

$(foreach bv, $(BUILD_VARIANTS), $(eval $(call define-build-obm,$(bv)) ) )

.PHONY:clean_obm
clean_obm:
	#nothing to do as the obm is not built from source.

