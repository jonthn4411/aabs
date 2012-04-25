
KERNEL_OUT:=$(SRC_DIR)/kernel/out/$(ABS_DROID_PRODUCT)

.PHONY: kernel
kernel:
	$(log) "KERNEL: Starting to build..."
	$(hide)cd $(SRC_DIR) && \
		source ./build/envsetup.sh && \
		chooseproduct $(ABS_DROID_PRODUCT) && choosetype $(ABS_DROID_TYPE) && choosevariant $(ABS_DROID_VARIANT) && \
		cd $(SRC_DIR)/kernel && make clean all 
	$(log) "KERNEL: Copying output files..."
	$(hide)mkdir -p $(OUTPUT_DIR)/prebuilt
	$(hide)cp $(KERNEL_OUT)/uImage.smp          $(OUTPUT_DIR)/prebuilt/uImage.smp
	$(hide)cp $(KERNEL_OUT)/uImage_recovery.smp $(OUTPUT_DIR)/prebuilt/uImage_recovery.smp
	$(hide)cp $(KERNEL_OUT)/uImage.cm           $(OUTPUT_DIR)/prebuilt/uImage.cm
	$(hide)cp $(KERNEL_OUT)/uImage_recovery.cm  $(OUTPUT_DIR)/prebuilt/uImage_recovery.cm
	$(hide)cp $(KERNEL_OUT)/rdinit              $(OUTPUT_DIR)/prebuilt
	$(hide)cp $(SRC_DIR)/kernel/rdroot/rdroot.tgz       $(OUTPUT_DIR)/prebuilt
	$(hide)cp $(SRC_DIR)/kernel/kernel/vmlinux          $(OUTPUT_DIR)/prebuilt
	$(hide)cp $(SRC_DIR)/kernel/kernel/System.map       $(OUTPUT_DIR)/prebuilt
	$(hide)rm -fr $(OUTPUT_DIR)/prebuilt/modules
	$(hide)cp -r $(KERNEL_OUT)/modules $(OUTPUT_DIR)/prebuilt/modules
	$(hide)cd $(OUTPUT_DIR)/prebuilt && tar czf modules.tgz modules/ 
	$(hide)cd $(KERNEL_OUT)/ && \
	        tar cvf telephony.tar telephony/ && \
	        cp telephony.tar $(OUTPUT_DIR)/prebuilt
	$(log) "KERNEL: Done:)"

PUBLISHING_FILES+=prebuilt/uImage.smp:m:md5
PUBLISHING_FILES+=prebuilt/uImage_recovery.smp:m:md5
PUBLISHING_FILES+=prebuilt/uImage.cm:m:md5
PUBLISHING_FILES+=prebuilt/uImage_recovery.cm:m:md5
PUBLISHING_FILES+=prebuilt/rdinit:m:md5
PUBLISHING_FILES+=prebuilt/rdroot.tgz:m:md5
PUBLISHING_FILES+=prebuilt/vmlinux:o:md5
PUBLISHING_FILES+=prebuilt/System.map:o:md5
PUBLISHING_FILES+=prebuilt/modules.tgz:m:md5
PUBLISHING_FILES+=prebuilt/telephony.tar:m:md5

#fixme(jason):all clean targets not verifeid yet
.PHONEY: clean_kernel
clean_kernel:
	rm -rf $(KERNEL_OUT)

build_device: kernel

