DROID_OUT:=$(SRC_DIR)/out/target/product/$(ABS_DROID_PRODUCT)
.PHONY: droid
droid:
	$(log) "DROID: Starting to build..."
	$(hide)cd $(SRC_DIR) && \
		source ./build/envsetup.sh && \
		chooseproduct $(ABS_DROID_PRODUCT) && choosetype $(ABS_DROID_TYPE) && choosevariant $(ABS_DROID_VARIANT) && \
		make -j$(MAKE_JOBS)
	$(log) "DROID: Copying output files..."
	$(hide)cp -p $(DROID_OUT)/primary_gpt_8g       $(OUTPUT_DIR)/prebuilt/
	$(hide)cp -p $(DROID_OUT)/secondary_gpt_8g     $(OUTPUT_DIR)/prebuilt/
	$(hide)cp -p $(DROID_OUT)/ramdisk.img          $(OUTPUT_DIR)/prebuilt/
	$(hide)cp -p $(DROID_OUT)/ramdisk_recovery.img $(OUTPUT_DIR)/prebuilt/
	$(hide)cp -p $(DROID_OUT)/system.img           $(OUTPUT_DIR)/prebuilt/
	$(hide)cp -p $(DROID_OUT)/userdata.img         $(OUTPUT_DIR)/prebuilt/
	$(hide)cp -a $(DROID_OUT)/symbols/system/lib $(OUTPUT_DIR)/prebuilt/ && \
		cd $(OUTPUT_DIR)/prebuilt && tar czf symbols_lib.tgz lib && rm lib -rf
	$(log) "DROID: Done:)"

PUBLISHING_FILES+=prebuilt/primary_gpt_8g:m:md5
PUBLISHING_FILES+=prebuilt/secondary_gpt_8g:m:md5
PUBLISHING_FILES+=prebuilt/ramdisk.img:m:md5
PUBLISHING_FILES+=prebuilt/ramdisk_recovery.img:m:md5
PUBLISHING_FILES+=prebuilt/system.img:m:md5
PUBLISHING_FILES+=prebuilt/userdata.img:o:md5
PUBLISHING_FILES+=prebuilt/symbols_lib.tgz:o:md5

build_device: droid

