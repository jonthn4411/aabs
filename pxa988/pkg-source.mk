INTERNAL_PROJECTS +=vendor/marvell/external/gps_sirf
INTERNAL_PROJECTS +=vendor/marvell/generic/apps/CmmbPlayer
INTERNAL_PROJECTS +=vendor/marvell/generic/apps/CmmbStack

.PHONY:pkgsrc
pkgsrc: output_dir get_source_for_pkg
	$(hide)echo "  save project list"
	$(hide)cd $(OUTPUT_DIR)/source && repo forall -c "echo -n \$$(pwd):;echo \$$REPO_PROJECT" > $(OUTPUT_DIR)/prjlist

	$(hide)echo "  remove internal source code..."
	$(hide)cd $(OUTPUT_DIR)/source && for prj in $(INTERNAL_PROJECTS); do rm -fr $$prj; done

	$(hide)echo "  package all source code..."
	$(hide)cd $(OUTPUT_DIR) && tar czf droid_all_src.tgz $(EXCLUDE_VCS) source/

	$(hide)echo "  package kernel source code..."
	$(hide)cd $(OUTPUT_DIR) && $(ABS_TOP_DIR)/core/gen_kernel_src_patch.sh $(KERNEL_BASE_COMMIT)

	$(hide)echo "  package uboot obm source code..."
	$(hide)cd $(OUTPUT_DIR) && $(ABS_TOP_DIR)/core/gen_uboot_obm_src_patch.sh $(UBOOT_BASE_COMMIT)

	$(hide)echo "  package android source code...,$(ANDROID_VERSION) $(BOARD) "
	$(hide)cd $(OUTPUT_DIR) && $(ABS_TOP_DIR)/core/gen_droid_src_patch.sh $(DROID_BASE) $(ABS_TOP_DIR)/core

	$(hide)cp $(ABS_TOP_DIR)/core/setup_android.sh $(OUTPUT_DIR)
	$(hide)cp $(BOARD)/release_package_list $(OUTPUT_DIR)/release_package_list
	$(log) "  done."

PUBLISHING_FILES+=release_package_list:o
