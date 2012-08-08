
define define-build-product-droid
build_product_droid_$(1):DROID_OUT:=$$(SRC_DIR)/out/target/product/$(1)
build_product_droid_$(1):
	$$(log) "DROID-$(1): Starting to build..."
	$$(hide)cd $$(SRC_DIR) && \
	       source ./build/envsetup.sh && \
	       chooseproduct $(1) && choosetype $$(ABS_DROID_TYPE) && choosevariant $$(ABS_DROID_VARIANT) && \
	       make -j$$(ABS_DROID_MAKE_JOBS)
	$$(log) "DROID-$(1): Copying output files..."
	$$(hide)cp -p $$(DROID_OUT)/primary_gpt_16g      $$(OUTPUT_DIR)/$(1)/
	$$(hide)cp -p $$(DROID_OUT)/secondary_gpt_16g    $$(OUTPUT_DIR)/$(1)/
	$$(hide)cp -p $$(DROID_OUT)/ramdisk.img          $$(OUTPUT_DIR)/$(1)/
	$$(hide)cp -p $$(DROID_OUT)/system.img           $$(OUTPUT_DIR)/$(1)/
	$$(hide)cp -p $$(DROID_OUT)/userdata.img         $$(OUTPUT_DIR)/$(1)/
	$$(hide)tar czf $$(OUTPUT_DIR)/$(1)/symbols_lib.tgz $$(DROID_OUT)/symbols/system/lib
	$$(log) "DROID-$(1): Done:)"

PUBLISHING_FILES+=$(1)/primary_gpt_16g:m:md5
PUBLISHING_FILES+=$(1)/secondary_gpt_16g:m:md5
PUBLISHING_FILES+=$(1)/ramdisk.img:m:md5
PUBLISHING_FILES+=$(1)/system.img:m:md5
PUBLISHING_FILES+=$(1)/userdata.img:o:md5
PUBLISHING_FILES+=$(1)/symbols_lib.tgz:o:md5
endef

$(foreach product,$(ABS_ALL_PRODUCTS), $(eval $(call define-build-product-droid,$(product)) ) )
