
define include-product-bootloader
include $$(ABS_SOC)/bootloader-$(1).mk
endef

$(foreach product,$(ABS_ALL_PRODUCTS),$(eval $(call include-product-bootloader,$(product))))

