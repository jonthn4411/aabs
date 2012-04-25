
.PHONY: droid

define define-droid-target
DROID_OUT:=$$(SRC_DIR)/out/target/product/$(1)
droid_$(1):
	$$(log) "DROID: Starting to build..."
	$$(hide)cd $$(SRC_DIR) && \
		source ./build/envsetup.sh && \
		chooseproduct $(1) && choosetype $$(ABS_DROID_TYPE) && choosevariant $$(ABS_DROID_VARIANT) && \
		make -j$$(MAKE_JOBS)
	$$(log) "DROID: Copying output files..."
	$$(hide)cp -p $$(DROID_OUT)/primary_gpt_8g       $$(OUTPUT_DIR)/$(1)/
	$$(hide)cp -p $$(DROID_OUT)/secondary_gpt_8g     $$(OUTPUT_DIR)/$(1)/
	$$(hide)cp -p $$(DROID_OUT)/ramdisk.img          $$(OUTPUT_DIR)/$(1)/
	$$(hide)cp -p $$(DROID_OUT)/ramdisk_recovery.img $$(OUTPUT_DIR)/$(1)/
	$$(hide)cp -p $$(DROID_OUT)/system.img           $$(OUTPUT_DIR)/$(1)/
	$$(hide)cp -p $$(DROID_OUT)/userdata.img         $$(OUTPUT_DIR)/$(1)/
	$$(hide)cp -a $$(DROID_OUT)/symbols/system/lib $$(OUTPUT_DIR)/$(1)/ && \
		cd $$(OUTPUT_DIR)/$(1) && tar czf symbols_lib.tgz lib && rm lib -rf
	$$(log) "DROID: Done:)"

PUBLISHING_FILES+=$(1)/primary_gpt_8g:m:md5
PUBLISHING_FILES+=$(1)/secondary_gpt_8g:m:md5
PUBLISHING_FILES+=$(1)/ramdisk.img:m:md5
PUBLISHING_FILES+=$(1)/ramdisk_recovery.img:m:md5
PUBLISHING_FILES+=$(1)/system.img:m:md5
PUBLISHING_FILES+=$(1)/userdata.img:o:md5
PUBLISHING_FILES+=$(1)/symbols_lib.tgz:o:md5

droid: droid_$(1)

endef

$(foreach bv,$(ABS_BUILD_DEVICES), $(eval $(call define-droid-target,$(bv)) ) )

build_device: droid

