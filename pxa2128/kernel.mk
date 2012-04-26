
SUPPER_PRODUCT:=orchid
KERNEL_OUT:=$(SRC_DIR)/kernel/out

.PHONY: kernel

kernel_build:
	$(log) "KERNEL: Starting to build..."
	$(hide)cd $(SRC_DIR) && \
		source ./build/envsetup.sh && \
		chooseproduct $(SUPPER_PRODUCT) && choosetype $(ABS_DROID_TYPE) && choosevariant $(ABS_DROID_VARIANT) && \
		cd $(SRC_DIR)/kernel && make clean all
	$(hide)cd $(KERNEL_OUT)/ && \
           tar czf modules.tgz modules/
	$(hide)cd $(KERNEL_OUT)/ && \
           tar cvf telephony.tar telephony/
	$(hide)mkdir -p $(OUTPUT_DIR)/$(SUPPER_PRODUCT)
	$(hide)cp $(KERNEL_OUT)/telephony.tar $(OUTPUT_DIR)/$(SUPPER_PRODUCT)/

kernel: kernel_build

PUBLISHING_FILES+=$(SUPPER_PRODUCT)/telephony.tar:m:md5

define define-kernel-copy
kernel_copy_$(1):
	$$(log) "KERNEL: Copying output files..."
	$$(hide)mkdir -p $$(OUTPUT_DIR)/$(1)
	$$(hide)cp $$(KERNEL_OUT)/uImage.smp          $$(OUTPUT_DIR)/$(1)
	$$(hide)cp $$(KERNEL_OUT)/uImage_recovery.smp $$(OUTPUT_DIR)/$(1)
	$$(hide)cp $$(KERNEL_OUT)/uImage.cm           $$(OUTPUT_DIR)/$(1)
	$$(hide)cp $$(KERNEL_OUT)/uImage_recovery.cm  $$(OUTPUT_DIR)/$(1)
	$$(hide)cp $$(KERNEL_OUT)/rdinit              $$(OUTPUT_DIR)/$(1)
	$$(hide)cp $$(SRC_DIR)/kernel/rdroot/rdroot.tgz    $$(OUTPUT_DIR)/$(1)
	$$(hide)cp $$(SRC_DIR)/kernel/kernel/vmlinux       $$(OUTPUT_DIR)/$(1)
	$$(hide)cp $$(SRC_DIR)/kernel/kernel/System.map    $$(OUTPUT_DIR)/$(1)
	$$(hide)cp $$(KERNEL_OUT)/modules.tgz           $$(OUTPUT_DIR)/$(1)
	$$(log) "KERNEL: Done:)"

kernel: kernel_copy_$(1)

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
	rm -rf $(KERNEL_OUT)

$(foreach bv,$(ABS_BUILD_DEVICES), $(eval $(call define-kernel-copy,$(bv)) ) )

build_device: kernel
