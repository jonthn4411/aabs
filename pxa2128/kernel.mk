
define define-build-product-kernel

build_product_kernel_$(1):
	$$(log) "KERNEL-$(1): Starting to build..."
	$$(hide)cd $$(SRC_DIR) && \
		source ./build/envsetup.sh && \
		chooseproduct $(1) && choosetype $$(ABS_DROID_TYPE) && choosevariant $$(ABS_DROID_VARIANT) && \
		cd $$(SRC_DIR)/kernel && make all
	$$(log) "KERNEL-$(1): Copying output files..."
	$$(hide)cp $$(SRC_DIR)/kernel/out/uImage              $$(OUTPUT_DIR)/$(1)/uImage
	$$(hide)cp $$(SRC_DIR)/kernel/kernel/vmlinux          $$(OUTPUT_DIR)/$(1)/
	$$(hide)cp $$(SRC_DIR)/kernel/kernel/System.map       $$(OUTPUT_DIR)/$(1)/
	$$(log) "KERNEL-$(1): Done:)"

PUBLISHING_FILES+=$(1)/uImage:m:md5
PUBLISHING_FILES+=$(1)/vmlinux:o:md5
PUBLISHING_FILES+=$(1)/System.map:o:md5

endef

$(foreach product,$(ABS_ALL_PRODUCTS), $(eval $(call define-build-product-kernel,$(product)) ) )

