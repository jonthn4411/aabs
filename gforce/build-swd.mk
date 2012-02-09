#check if the required variables have been set.
$(call check-variables,BUILD_VARIANTS)

SWD_DIR:=vendor/marvell/generic/software_downloader

#$1:build variant
define define-build-swd
#format: <file name>:[m|o]:[md5]
#m:means mandatory
#o:means optional
#md5: need to generate md5 sum
PUBLISHING_FILES_$(1)+=$(1)/Software_Downloader.zip:m:md5

.PHONY:build_swd_$(1)
build_swd_$(1):
	$$(log) "starting($(1)) to build software download"
	$(hide)mkdir -p $$(OUTPUT_DIR)/Software_Downloader
	$(hide)cp -a $(SRC_DIR)/$(SWD_DIR)/* $$(OUTPUT_DIR)/Software_Downloader/
	$(hide)cd $$(OUTPUT_DIR) && zip -r $(1)/Software_Downloader.zip Software_Downloader && \
		rm -rf Software_Downloader
	$$(log) "  done."
endef

$(foreach bv, $(BUILD_VARIANTS), $(eval $(call define-build-swd,$(bv)) ) )

.PHONY:clean_swd
clean_swd:
	$(log) "cleaning software downloader ..."
	rm $(OUTPUT_DIR)/Software_Downloader.zip -rf && \
	$(log) "    done."



