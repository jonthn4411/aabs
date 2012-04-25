
KERNEL_OUT:=$(SRC_DIR)/kernel/out

.PHONY: kernel
define define-kernel-target
kernel_$(1):
	$$(log) "KERNEL: Starting to build..."
	$$(hide)cd $$(SRC_DIR) && \
		source ./build/envsetup.sh && \
		chooseproduct $(1) && choosetype $$(ABS_DROID_TYPE) && choosevariant $$(ABS_DROID_VARIANT) && \
		cd $$(SRC_DIR)/kernel && make clean all
	$$(log) "KERNEL: Copying output files..."
	$$(hide)mkdir -p $$(OUTPUT_DIR)/$(1)
	$$(hide)cp $$(KERNEL_OUT)/$(1)/uImage.smp          $$(OUTPUT_DIR)/$(1)/uImage.smp
	$$(hide)cp $$(KERNEL_OUT)/$(1)/uImage_recovery.smp $$(OUTPUT_DIR)/$(1)/uImage_recovery.smp
	$$(hide)cp $$(KERNEL_OUT)/$(1)/uImage.cm           $$(OUTPUT_DIR)/$(1)/uImage.cm
	$$(hide)cp $$(KERNEL_OUT)/$(1)/uImage_recovery.cm  $$(OUTPUT_DIR)/$(1)/uImage_recovery.cm
	$$(hide)cp $$(KERNEL_OUT)/$(1)/rdinit              $$(OUTPUT_DIR)/$(1)
	$$(hide)cp $$(SRC_DIR)/kernel/rdroot/rdroot.tgz      $$(OUTPUT_DIR)/$(1)
	$$(hide)cp $$(SRC_DIR)/kernel/kernel/vmlinux         $$(OUTPUT_DIR)/$(1)
	$$(hide)cp $$(SRC_DIR)/kernel/kernel/System.map      $$(OUTPUT_DIR)/$(1)
	$$(hide)rm -fr $$(OUTPUT_DIR)/$(1)/modules
	$$(hide)cp -r $$(KERNEL_OUT)/$(1)/modules $$(OUTPUT_DIR)/$(1)/modules
	$$(hide)cd $$(OUTPUT_DIR)/$(1) && tar czf modules.tgz modules/ 
	$$(log) "KERNEL: Done:)"

kernel: kernel_$(1)

PUBLISHING_FILES+=$(1)/uImage.smp:m:md5
PUBLISHING_FILES+=$(1)/uImage_recovery.smp:m:md5
PUBLISHING_FILES+=$(1)/uImage.cm:m:md5
PUBLISHING_FILES+=$(1)/uImage_recovery.cm:m:md5
PUBLISHING_FILES+=$(1)/rdinit:m:md5
PUBLISHING_FILES+=$(1)/rdroot.tgz:m:md5
PUBLISHING_FILES+=$(1)/vmlinux:o:md5
PUBLISHING_FILES+=$(1)/System.map:o:md5
PUBLISHING_FILES+=$(1)/modules.tgz:m:md5

endef

#fixme(jason):all clean targets not verifeid yet
.PHONEY: clean_kernel
clean_kernel:
	rm -rf $$(KERNEL_OUT)

$(foreach bv,$(ABS_BUILD_DEVICES), $(eval $(call define-kernel-target,$(bv)) ) )

build_device: kernel
