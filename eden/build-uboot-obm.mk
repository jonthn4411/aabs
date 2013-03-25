BOOT_SRC_DIR:=boot
BOOT_OUT_DIR:=$(BOOT_SRC_DIR)/out
UBOOT:=u-boot.bin

#$1:build variant
define define-build-uboot-obm
tw:=$$(subst :,  , $(1))
product:=$$(word 1, $$(tw))
device:=$$(word 2, $$(tw))

#format: <file name>:[m|o]:[md5]
#m:means mandatory
#o:means optional
#md5: need to generate md5 sum
PUBLISHING_FILES+=$$(product)/$(UBOOT):m:md5

.PHONY:build_uboot_obm_$$(product)
build_uboot_obm_$$(product): private_product:=$$(product)
build_uboot_obm_$$(product): private_device:=$$(device)
build_uboot_obm_$$(product): build_droid_root_$$(product)
	$$(log) "starting($$(private_product) to build uboot"
	$$(hide)cd $$(SRC_DIR) && \
	. $$(ABS_TOP_DIR)/tools/apb $$(private_product) && \
	choosetype $$(DROID_TYPE) && choosevariant $$(DROID_VARIANT) && \
	cd $$(BOOT_SRC_DIR) && \
	make all
	$$(hide)mkdir -p $$(OUTPUT_DIR)/$$(private_product)/
	$$(log) "start to copy uboot files"
	$$(hide)cp $$(SRC_DIR)/$$(BOOT_OUT_DIR)/$$(UBOOT) $$(OUTPUT_DIR)/$$(private_product)/
	$$(log) "  done."
endef

define define-clean-uboot-obm
tw:=$$(subst :,  , $(1))
product:=$$(word 1, $$(tw))
device:=$$(word 2, $$(tw))

.PHONY:clean_uboot_obm_$$(product)
clean_uboot_obm_$$(product): private_product:=$$(product)
clean_uboot_obm_$$(product): private_device:=$$(device)
clean_uboot_obm_$$(product):
	$(log) "cleaning uboot and obm..."
	$(hide)cd $(SRC_DIR)/$(BOOT_SRC_DIR) && \
	. $$(ABS_TOP_DIR)/tools/apb $$(private_product) && \
	choosetype $$(DROID_TYPE) && choosevariant $$(DROID_VARIANT) && \
	make clean
	$(log) "    done."
endef
