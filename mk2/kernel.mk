
ifneq ($(PLATFORM_ANDROID_VARIANT),)
       DROID_VARIANT:=$(PLATFORM_ANDROID_VARIANT)
else
       DROID_VARIANT:=userdebug
endif

.PHONY: kernel
kernel:
	$(log) "KERNEL: Starting to build..."
	$(hide)cd $(SRC_DIR) && \
		source ./build/envsetup.sh && \
		chooseproduct $(ABS_DROID_PRODUCT) && choosetype $(ABS_DROID_TYPE) && choosevariant $(DROID_VARIANT) && \
		cd $(SRC_DIR)/kernel && make all
	$(log) "KERNEL: Copying output files..."
	$(hide)mkdir -p $(OUTPUT_DIR)/prebuilt
	$(hide)cp $(SRC_DIR)/kernel/out/uImage.smp          $(OUTPUT_DIR)/prebuilt/uImage.smp
	$(hide)cp $(SRC_DIR)/kernel/out/uImage_recovery.smp $(OUTPUT_DIR)/prebuilt/uImage_recovery.smp
	$(hide)cp $(SRC_DIR)/kernel/kernel/vmlinux          $(OUTPUT_DIR)/prebuilt
	$(hide)cp $(SRC_DIR)/kernel/kernel/System.map       $(OUTPUT_DIR)/prebuilt
	$(log) "KERNEL: Done:)"

PUBLISHING_FILES+=prebuilt/uImage.smp:m:md5
PUBLISHING_FILES+=prebuilt/uImage_recovery.smp:m:md5
PUBLISHING_FILES+=prebuilt/vmlinux:o:md5
PUBLISHING_FILES+=prebuilt/System.map:o:md5

#fixme(jason):all clean targets not verifeid yet
.PHONEY: clean_kernel
clean_kernel:
	rm -rf $(SRC_DIR)/kernel/out

build_device: kernel

