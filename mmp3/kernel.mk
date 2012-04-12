
.PHONY: kernel
kernel:
	$(log) "KERNEL: Starting to build..."
	$(hide)cd $(SRC_DIR) && \
		source ./build/envsetup.sh && \
		chooseproduct $(ABS_DROID_PRODUCT) && choosetype $(ABS_DROID_TYPE) && choosevariant $(ABS_DROID_VARIANT) && \
		cd $(SRC_DIR)/kernel && make clean all 
	$(log) "KERNEL: Copying output files..."
	$(hide)mkdir -p $(OUTPUT_DIR)/prebuilt
	$(hide)cp $(SRC_DIR)/kernel/out/uImage.smp          $(OUTPUT_DIR)/prebuilt/uImage.smp
	$(hide)cp $(SRC_DIR)/kernel/out/uImage_recovery.smp $(OUTPUT_DIR)/prebuilt/uImage_recovery.smp
	$(hide)cp $(SRC_DIR)/kernel/out/uImage.cm           $(OUTPUT_DIR)/prebuilt/uImage.cm
	$(hide)cp $(SRC_DIR)/kernel/out/uImage_recovery.cm  $(OUTPUT_DIR)/prebuilt/uImage_recovery.cm
	$(hide)cp $(SRC_DIR)/kernel/out/rdinit              $(OUTPUT_DIR)/prebuilt
	$(hide)cp $(SRC_DIR)/kernel/rdroot/rdroot.tgz       $(OUTPUT_DIR)/prebuilt
	$(hide)cp $(SRC_DIR)/kernel/kernel/vmlinux          $(OUTPUT_DIR)/prebuilt
	$(hide)cp $(SRC_DIR)/kernel/kernel/System.map       $(OUTPUT_DIR)/prebuilt
	$(hide)rm -fr $(OUTPUT_DIR)/prebuilt/modules
	$(hide)cp -r $(SRC_DIR)/kernel/out/modules $(OUTPUT_DIR)/prebuilt/modules
	$(hide)cd $(OUTPUT_DIR)/prebuilt && tar czf modules.tgz modules/ 
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

#fixme(jason):all clean targets not verifeid yet
.PHONEY: clean_kernel
clean_kernel:
	rm -rf $(SRC_DIR)/kernel/out

build_device: kernel

