ifneq ($(strip $(ABS_VIRTUAL_BUILD) ),true)
#make sure the last character of $(SRC_DIR) is not "/"
.PHONY:get_source_for_pkg
get_source_for_pkg: output_dir
	$(log) "Package source code using the $(OUTPUT_DIR)/manifest.xml"
	#check if $(OUTPUT_DIR)/manifest.xml is generated already
	$(hide)[ -s $(OUTPUT_DIR)/manifest.xml ]

	$(hide)if [ -d "$(OUTPUT_DIR)/source" ]; then \
		rm -fr $(OUTPUT_DIR)/source; \
	fi

	$(hide)mkdir -p $(OUTPUT_DIR)/source

	$(hide)cd $(OUTPUT_DIR)/source/ && \
	ln -s $(SRC_DIR)/.repo .repo

	$(log) " getting source code using manifest.xml"
	$(hide)cd $(OUTPUT_DIR)/source && \
	cp $(OUTPUT_DIR)/manifest.xml $(OUTPUT_DIR)/source/.repo/manifests/autobuild.xml && \
	repo init -m autobuild.xml && \
	repo sync -l 


# Platform hook
-include $(ABS_SOC)/pkg-source.mk
endif

