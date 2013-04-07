DROID_OUT:=$(SRC_DIR)/out/target/product/$(ABS_DROID_PRODUCT)
.PHONY: droidupdate

ifneq ($(PLATFORM_ANDROID_VARIANT),)
       DROID_VARIANT:=$(PLATFORM_ANDROID_VARIANT)
else
       DROID_VARIANT:=userdebug
endif

droidupdate:
	$(log) "DROID UPDATE: Starting to build..."
	$(hide)cd $(SRC_DIR) && \
		source ./build/envsetup.sh && \
		chooseproduct $(ABS_DROID_PRODUCT) && choosetype $(ABS_DROID_TYPE) && choosevariant $(DROID_VARIANT) && \
		make droidupdate -j$(MAKE_JOBS)
	$(log) "DROID UPDATE: Copying output files..."
	$(hide)cp -p $(DROID_OUT)/update_droid.zip    $(OUTPUT_DIR)/prebuilt/
	$(hide)cp -p $(DROID_OUT)/update_recovery.zip $(OUTPUT_DIR)/prebuilt/
	$(log) "DROID UPDATE: Done:)"

PUBLISHING_FILES+=prebuilt/update_droid.zip:m:md5
PUBLISHING_FILES+=prebuilt/update_recovery.zip:m:md5

build_device: droidupdate

