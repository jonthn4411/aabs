include core/pkg-source.mk

.PHONY:pkgsrc
pkgsrc: output_dir get_source_for_pkg
	$(hide)$(TOP_DIR)/avd1/pkgsrc.sh $(OUTPUT_DIR)
	$(log) "  done."


#format: <file name>:[m|o]:[md5]
#m:means mandatory
#o:means optional
#md5: need to generate md5 sum
PUBLISHING_FILES+=kernel_src.tgz:o:md5 \
	droid_src.tgz:o:md5 \
	drivers_src.tgz:o:md5\
	boot_src.tgz:o:md5

