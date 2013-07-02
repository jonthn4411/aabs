#check if the required variables have been set.
#$(call check-variables,)

SWD_DIR:=vendor/marvell/generic/software_downloader

#$1:build variant
define define-build-swd
tw:=$$(subst :,  , $(1))
product:=$$(word 1, $$(tw))
device:=$$(word 2, $$(tw))

#format: <file name>:<dst folder>:[m|o]:[md5]
#m:means mandatory
#o:means optional
#
#md5: need to generate md5 sum
PUBLISHING_FILES2+=Software_Downloader_$$(device).zip:tools:o:md5

.PHONY:build_swd_$$(product)
build_swd_$$(product): private_product:=$$(product)
build_swd_$$(product): private_device:=$$(device)
build_swd_$$(product): build_obm_$$(product)
build_swd_$$(product): output_dir
	$$(log) "starting($$(private_product)) to build software downloader"
	$$(hide)mkdir -p $$(OUTPUT_DIR)/Software_Downloader_$$(private_device)
	$$(hide)cp -a $$(SRC_DIR)/$$(SWD_DIR)/* $$(OUTPUT_DIR)/Software_Downloader_$$(private_device)/
	$$(hide)if [ -f $$(OUTPUT_DIR)/$$(private_product)/EDEN_NonTLoader_eMMC_DDR.bin ]; then cp -f $$(OUTPUT_DIR)/$$(private_product)/EDEN_NonTLoader_eMMC_DDR.bin $$(OUTPUT_DIR)/Software_Downloader_$$(private_device)/EDEN_DKB; fi
	$$(hide)if [ -f $$(OUTPUT_DIR)/$$(private_product)/EDEN_TLoader_eMMC_DDR.bin ]; then cp -f $$(OUTPUT_DIR)/$$(private_product)/EDEN_TLoader_eMMC_DDR.bin $$(OUTPUT_DIR)/Software_Downloader_$$(private_device)/EDEN_DKB; fi
	$$(hide)cd $$(OUTPUT_DIR) && zip -r Software_Downloader_$$(private_device).zip Software_Downloader_$$(private_device) && \
	rm -rf Software_Downloader_$$(private_device)
	$$(log) "  done."
endef
