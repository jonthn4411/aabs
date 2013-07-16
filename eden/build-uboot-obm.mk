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

tw:=$$(subst :,  , $(2))
os:=$$(word 1, $$(tw))
kernel_cfg:=$$(word 2, $$(tw))

tw:=$$(subst :,  , $(3))
boot_cfg:=$$(word 1, $$(tw))

.PHONY:build_obm_$$(product)
build_obm_$$(product): build_obm_$$(product)_$$(kernel_cfg)_$$(boot_cfg)

build_obm_$$(product)_$$(kernel_cfg)_$$(boot_cfg): private_product:=$$(product)
build_obm_$$(product)_$$(kernel_cfg)_$$(boot_cfg): private_device:=$$(device)
build_obm_$$(product)_$$(kernel_cfg)_$$(boot_cfg): private_kcfg:=$$(kernel_cfg)
build_obm_$$(product)_$$(kernel_cfg)_$$(boot_cfg): private_bcfg:=$$(boot_cfg)
build_obm_$$(product)_$$(kernel_cfg)_$$(boot_cfg): output_dir
	$$(log) "starting($$(private_product) kc($$(private_kcfg)) bc($$(private_bcfg)) to build obm"
	$$(hide)cd $$(SRC_DIR) && \
	. build/envsetup.sh && \
	lunch $$(private_product)-$$(DROID_VARIANT) && \
	cd $$(BOOT_SRC_DIR) && KERNEL_CONFIG=$$(private_kcfg) UBOOT_CONFIG=$$(private_bcfg) make obm && \
	cd $$(SRC_DIR) && KERNEL_CONFIG=$$(private_kcfg) UBOOT_CONFIG=$$(private_bcfg) make mrvlotapackage
	$$(hide)echo "  copy OTA package ..."
	$$(hide)cp -p -r $$(SRC_DIR)/out/target/product/$$(private_device)/$$(private_product)_$$(private_kcfg)_$$(private_bcfg)-ota-mrvl.zip $$(OUTPUT_DIR)/$$(private_product)
	$$(hide)cp -p -r $$(SRC_DIR)/out/target/product/$$(private_device)/$$(private_product)_$$(private_kcfg)_$$(private_bcfg)-ota-mrvl-recovery.zip $$(OUTPUT_DIR)/$$(private_product)
	$$(hide)cp -p -r $$(SRC_DIR)/out/target/product/$$(private_device)/obj/PACKAGING/target_files_intermediates/$$(private_product)_$$(private_kcfg)_$$(private_bcfg)-target_files.zip $$(OUTPUT_DIR)/$$(private_product)/$(private_product)_$$(private_kcfg)_$$(private_bcfg)-ota-mrvl-intermediates.zip
	$(log) "  done for OTA package build."
	$$(log) "  done."

PUBLISHING_FILES+=$$(product)/$$(product)_$$(kernel_cfg)_$$(boot_cfg)-ota-mrvl.zip:o:md5
PUBLISHING_FILES+=$$(product)/$$(product)-$$(kernel_cfg)_$$(boot_cfg)-ota-mrvl-recovery.zip:o:md5
PUBLISHING_FILES+=$$(product)/$$(product)-$$(kernel_cfg)_$$(boot_cfg)-ota-mrvl-intermediates.zip:o:md5

endef
