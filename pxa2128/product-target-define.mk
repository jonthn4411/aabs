
.PHONY: all_products

define define-build-product
output_dir_$(1):
	$(hide)mkdir -p $(OUTPUT_DIR)/$(1)
build_product_$(1): output_dir_$(1)
build_product_$(1): build_product_kernel_$(1)
build_product_$(1): build_product_droid_$(1)
build_product_$(1): build_product_bootloader_$(1)
#build_product_$(1): build_product_droidupdate_$(1)
all_products:build_product_$(1)

endef

$(foreach product, $(ABS_ALL_PRODUCTS), $(eval $(call define-build-product,$(product) ) ))

build: all_products

