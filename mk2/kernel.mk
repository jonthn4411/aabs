
.PHONY: kernel
kernel:
	$(log) "KERNEL: Starting to build..."
	$(hide)cd $(SRC_DIR) && \
		source ./build/envsetup.sh && \
		chooseproduct $(ABS_DROID_PRODUCT) && choosetype $(ABS_DROID_TYPE) && choosevariant $(ABS_DROID_VARIANT) && \
		cd $(SRC_DIR)/kernel && make all
	$(log) "KERNEL: Copying output files..."
	$(hide)mkdir -p $(OUTPUT_DIR)/prebuilt
	$(hide)cp $(SRC_DIR)/kernel/out/uImage          $(OUTPUT_DIR)/prebuilt/uImage
	$(hide)cp $(SRC_DIR)/kernel/out/uImage_recovery $(OUTPUT_DIR)/prebuilt/uImage_recovery
	$(hide)cp $(SRC_DIR)/kernel/kernel/vmlinux          $(OUTPUT_DIR)/prebuilt
	$(hide)cp $(SRC_DIR)/kernel/kernel/System.map       $(OUTPUT_DIR)/prebuilt
	$(log) "KERNEL: Done:)"

PUBLISHING_FILES+=prebuilt/uImage:m:md5
PUBLISHING_FILES+=prebuilt/uImage_recovery:m:md5
PUBLISHING_FILES+=prebuilt/vmlinux:o:md5
PUBLISHING_FILES+=prebuilt/System.map:o:md5

#fixme(jason):all clean targets not verifeid yet
.PHONEY: clean_kernel
clean_kernel:
	rm -rf $(SRC_DIR)/kernel/out

build_device: kernel
