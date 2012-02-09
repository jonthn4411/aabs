#check if the required variables have been set.
$(call check-variables,UBOOT_CONFIG UBOOT_SRC_DIR BUILD_VARIANTS)

#$1:build variant
define define-build-uboot

#format: <file name>:[m|o]:[md5]
#m:means mandatory
#o:means optional
#md5: need to generate md5 sum
PUBLISHING_FILES+=$(1)/u-boot.bin:m:md5

.PHONY:build_uboot_$(1)
build_uboot_$(1):
	$$(log) "starting($(1)) to build uboot"
	$$(hide)cd $$(SRC_DIR)/$$(UBOOT_SRC_DIR) && \
	export ARCH=arm && \
	export CROSS_COMPILE="$$(SRC_DIR)/vendor/marvell/generic/toolchain/arm-marvell-linux-gnueabi-vfp-4.2.0/bin/arm-marvell-linux-gnueabi-" && \
	make $$(UBOOT_CONFIG) && \
	make 
	$$(hide)mkdir -p $$(OUTPUT_DIR)/$(1)
	$$(hide)cp $$(SRC_DIR)/$$(UBOOT_SRC_DIR)/u-boot.bin $$(OUTPUT_DIR)/$(1)
	$$(log) "  done."
endef

$(foreach bv, $(BUILD_VARIANTS), $(eval $(call define-build-uboot,$(bv)) ) )

.PHONY:clean_uboot
clean_uboot:
	$(log) "cleaning uboot..."
	$(hide)cd $(SRC_DIR)/$(UBOOT_SRC_DIR) && \
	export ARCH=arm && \
	make $(UBOOT_CONFIG) && \
	make clean
	$(log) "    done."
