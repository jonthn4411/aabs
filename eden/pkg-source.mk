PUBLISHING_FILES2+=delta_patches.tgz:src:o
PUBLISHING_FILES2+=delta_patches.base:src:o

.PHONY:pkgsrc

#format: <file name>:[m|o]:[md5]
#m:means mandatory
#o:means optional
#md5: need to generate md5 sum
PUBLISHING_FILES+=$(ANDROID_VERSION)_RN.pdf:o

publish_RN:
	>...$(hide)cp $(ABS_SOC)/$(ANDROID_VERSION)_RN.pdf $(OUTPUT_DIR)

#pkgsrc: publish_RN

save_prjlist: get_source_for_pkg
	$(hide)echo "  save project list"
	$(hide)cd $(OUTPUT_DIR)/source && repo forall -c "echo -n \$$(pwd):;echo \$$REPO_PROJECT" > $(OUTPUT_DIR)/prjlist

remove_internal_src: get_source_for_pkg
	$(hide)echo "  remove internal source code..."
	$(hide)cd $(OUTPUT_DIR)/source && for prj in $(INTERNAL_PROJECTS); do rm -fr $$prj; done

pkg_all_src: get_source_for_pkg
	$(hide)echo "  package all source code..."
	$(hide)cd $(OUTPUT_DIR) && tar czf droid_all_src.tgz $(EXCLUDE_VCS) source/

pkg_kernel_src: output_dir
	$(hide)echo "  package kernel source code..."
	$(hide)cd $(OUTPUT_DIR) && $(ABS_TOP_DIR)/core/gen_kernel_src_patch.sh $(KERNEL_BASE_COMMIT)

pkg_boot_src: output_dir
	$(hide)echo "  package uboot obm source code..."
	$(hide)cd $(OUTPUT_DIR) && $(ABS_TOP_DIR)/core/gen_uboot_obm_src_patch.sh $(UBOOT_BASE_COMMIT)

pkg_droid_src: output_dir
	$(hide)echo "  package android source code..."
	$(hide)cd $(OUTPUT_DIR) && $(ABS_TOP_DIR)/core/gen_droid_src_patch.sh $(DROID_BASE) $(ABS_TOP_DIR)/core $(ABS_TOP_DIR)/core/$(HEAD_MANIFEST)

LAST_MS1_FILE=${LAST_BUILD_LOC}/"LAST_MS1.${ABS_RELEASE_FULL_NAME}"

delta_patches: output_dir pkg_droid_src
	$(hide)echo "  extract delta patches since ms1..."
	$(hide)cd $(OUTPUT_DIR) && $(ABS_TOP_DIR)/core/gen_delta_patch.sh $(SRC_DIR) $(ABS_TOP_DIR)/tools $(LAST_MS1_FILE) $(OUTPUT_DIR)/changelog.ms1

publish_setup_sh: output_dir
	$(hide)cp $(ABS_TOP_DIR)/core/setup_android.sh $(OUTPUT_DIR)

pkgsrc: save_prjlist
pkgsrc: remove_internal_src
pkgsrc: pkg_all_src
pkgsrc: pkg_kernel_src
pkgsrc: pkg_boot_src
pkgsrc: pkg_droid_src
pkgsrc: delta_patches
pkgsrc: publish_setup_sh
	$(log) "  done."
