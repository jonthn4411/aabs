#check if the required variables have been set.
#$(call check-variables,)

SWD_DIR:=vendor/marvell/generic/software_downloader

#format: <file name>:<dst folder>:[m|o]:[md5]
#m:means mandatory
#o:means optional
#
#md5: need to generate md5 sum
PUBLISHING_FILES2+=Software_Downloader.zip:tools:o:md5

.PHONY:build_swd
build_swd:
	$(log) "starting($(1)) to build software download"
	$(hide)mkdir -p $(OUTPUT_DIR)/Software_Downloader
	$(hide)cp -a $(SRC_DIR)/$(SWD_DIR)/* $(OUTPUT_DIR)/Software_Downloader/
	$(hide)cd $(OUTPUT_DIR) && zip -r Software_Downloader.zip Software_Downloader && \
		rm -rf Software_Downloader
	$(log) "  done."

.PHONY:clean_swd
clean_swd:
	$(log) "cleaning software downloader ..."
	rm $(OUTPUT_DIR)/Software_Downloader.zip -rf && \
	$(log) "    done."



