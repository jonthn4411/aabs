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
build_swd_$$(product): soutput:=$$(SRC_DIR)/out/target/product/$$(device)/swdbuild
build_swd_$$(product): output_dir
	$$(log) "starting($$(private_product)) to build software downloader"
	$$(hide)cp -rp $$(SRC_DIR)/$$(SWD_DIR)/* $$(soutput)
	$$(hide)cd $$(soutput)/.. && zip -r Software_Downloader_$$(private_device).zip swdbuild && mv Software_Downloader_$$(private_device).zip $$(OUTPUT_DIR)
	$$(log) "  done."
endef
