#check if the required variables have been set.
$(call check-variables,OBM_SRC_DIR BUILD_VARIANTS)

OBM_NTIM_1:=ntim_mmp2_nand_bbu_ddr.bin
OBM_DESC_1:=ntim_mmp2_nand_bbu_ddr_elipda_512m.txt

OBM_NTLOADER_1:=MMP2_NTLOADER_3_2_15.bin
WTM:=Wtm_rel_mmp2.bin

OBM_BIN_DIR:=binaries/BootLoader
#$1:build variant
define define-build-obm

#format: <file name>:[m|o]:[md5]
#m:means mandatory
#o:means optional
#md5: need to generate md5 sum
PUBLISHING_FILES_$(1)+=$(1)/$(OBM_NTLOADER_1):m:md5
PUBLISHING_FILES_$(1)+=$(1)/$(OBM_NTIM_1):m:md5
PUBLISHING_FILES_$(1)+=$(1)/$(OBM_DESC_1):m:md5
PUBLISHING_FILES_$(1)+=$(1)/$(WTM):m:md5

.PHONY:build_obm_$(1)
build_obm_$(1):
	$$(log) "start to copy obm files"
	$$(hide)mkdir -p $$(OUTPUT_DIR)/$(1)
	$$(hide)cp $$(SRC_DIR)/boot/out/$$(OBM_NTLOADER_1) $$(OUTPUT_DIR)/$(1)
	$$(hide)cp $$(SRC_DIR)/boot/out/$$(OBM_NTIM_1) $$(OUTPUT_DIR)/$(1)
	$$(hide)cp $$(SRC_DIR)/boot/out/$$(OBM_DESC_1) $$(OUTPUT_DIR)/$(1)
	$$(hide)cp $$(SRC_DIR)/boot/out/$$(WTM) $$(OUTPUT_DIR)/$(1)
	$$(log) "  done."
endef

$(foreach bv, $(BUILD_VARIANTS), $(eval $(call define-build-obm,$(bv)) ) )

.PHONY:clean_obm
clean_obm:
	#nothing to do as the obm is not built from source.

