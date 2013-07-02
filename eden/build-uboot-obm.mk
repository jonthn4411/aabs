BOOT_SRC_DIR:=boot
BOOT_OUT_DIR:=$(BOOT_SRC_DIR)/out

#$1:build device
#$2:uboot_config
define define-uboot-target
tw:=$$(subst :,  , $(1))
product:=$$(word 1, $$(tw))
device:=$$(word 2, $$(tw))

tw:=$$(subst :,  , $(2))
boot_cfg:=$$(word 1, $$(tw))

#format: <file name>:[m|o]:[md5]
#m:means mandatory
#o:means optional
#md5: need to generate md5 sum
PUBLISHING_FILES+=$$(product)/u-boot.bin.$$(boot_cfg):m:md5

build_uboot_$$(product): build_uboot_$$(boot_cfg)

.PHONY:build_uboot_$$(boot_cfg)
build_uboot_$$(boot_cfg): private_product:=$$(product)
build_uboot_$$(boot_cfg): private_device:=$$(device)
build_uboot_$$(boot_cfg): private_cfg:=$$(boot_cfg)
build_uboot_$$(boot_cfg): uoutput:=$$(SRC_DIR)/out/target/product/$$(device)/ubuild-$$(boot_cfg)
build_uboot_$$(boot_cfg): output_dir
	$$(log) "starting($$(private_product) to build uboot"
	$$(hide)cd $$(SRC_DIR) && \
	. build/envsetup.sh && \
	lunch $$(private_product)-$$(DROID_VARIANT) && \
	cd $$(BOOT_SRC_DIR) && \
	UBOOT_CONFIG=$$(private_cfg) make uboot
	$$(hide)mkdir -p $$(OUTPUT_DIR)/$$(private_product)/
	$$(log) "start to copy uboot files"
	$$(hide)if [ -f $$(uoutput)/u-boot.bin ]; then cp $$(uoutput)/u-boot.bin $$(OUTPUT_DIR)/$$(private_product)/u-boot.bin.$$(private_cfg); fi
	$$(log) "  done."
endef

#$1:build variant
define define-build-obm
tw:=$$(subst :,  , $(1))
product:=$$(word 1, $$(tw))
device:=$$(word 2, $$(tw))

.PHONY:build_obm_$$(product)
build_obm_$$(product): private_product:=$$(product)
build_obm_$$(product): private_device:=$$(device)
build_obm_$$(product): ooutput:=$$(SRC_DIR)/out/target/product/$$(device)/obuild
build_obm_$$(product): output_dir
	$$(log) "starting($$(private_product) to build obm"
	$$(hide)cd $$(SRC_DIR) && \
	. build/envsetup.sh && \
	lunch $$(private_product)-$$(DROID_VARIANT) && \
	cd $$(BOOT_SRC_DIR) && make obm
	$$(hide)mkdir -p $$(OUTPUT_DIR)/$$(private_product)/
	$$(log) "start to copy obm files"
	$$(hide)if [ -f $$(ooutput)/Bootloader_3.3.7_Linux/EDEN_DKB/EDEN_NonTLoader_eMMC_DDR.bin ]; then cp $$(ooutput)/Bootloader_3.3.7_Linux/EDEN_DKB/EDEN_NonTLoader_eMMC_DDR.bin $$(OUTPUT_DIR)/$$(private_product)/; fi
	$$(hide)if [ -f $$(ooutput)/Bootloader_3.3.7_Linux/EDEN_DKB/EDEN_TLoader_eMMC_DDR.bin ]; then cp $$(ooutput)/Bootloader_3.3.7_Linux/EDEN_DKB/EDEN_TLoader_eMMC_DDR.bin $$(OUTPUT_DIR)/$$(private_product)/; fi
	$$(log) "  done."

endef
