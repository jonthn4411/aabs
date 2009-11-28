#check if the required variables have been set.
$(call check-variables,OBM_SRC_DIR BUILD_VARIANTS)

OBM_NTIM_STEM:=NTIM_OBM_uboot_ASPEN_Mode
OBM_NTLOADER:=ASPN_NTLOADER.bin

#$1:build variant
define define-build-obm

#format: <file name>:[m|o]:[md5]
#m:means mandatory
#o:means optional
#md5: need to generate md5 sum
PUBLISHING_FILES_$(1)+=$(1)/$(OBM_NTLOADER):m:md5
PUBLISHING_FILES_$(1)+=$(1)/$(OBM_NTIM_STEM)2.bin:m:md5
PUBLISHING_FILES_$(1)+=$(1)/$(OBM_NTIM_STEM)3.bin:m:md5
PUBLISHING_FILES_$(1)+=$(1)/$(OBM_NTIM_STEM)5.bin:m:md5

.PHONY:build_obm_$(1)
build_obm_$(1):
	$$(log) "start to copy obm files"
	$$(hide)mkdir -p $$(OUTPUT_DIR)/$(1)
	$$(hide)cp $$(SRC_DIR)/$$(OBM_SRC_DIR)/binaries/avengers/$$(OBM_NTLOADER) $$(OUTPUT_DIR)/$(1)
	$$(hide)cp $$(SRC_DIR)/$$(OBM_SRC_DIR)/binaries/avengers/$$(OBM_NTIM_STEM)2.bin $$(OUTPUT_DIR)/$(1)
	$$(hide)cp $$(SRC_DIR)/$$(OBM_SRC_DIR)/binaries/avengers/$$(OBM_NTIM_STEM)3.bin $$(OUTPUT_DIR)/$(1)
	$$(hide)cp $$(SRC_DIR)/$$(OBM_SRC_DIR)/binaries/avengers/$$(OBM_NTIM_STEM)5.bin $$(OUTPUT_DIR)/$(1)
	$$(log) "  done."
endef

$(foreach bv, $(BUILD_VARIANTS), $(eval $(call define-build-obm,$(bv)) ) )

.PHONY:clean_obm
clean_obm:
	#nothing to do as the obm is not built from source.

