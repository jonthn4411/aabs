include core/pkg-source.mk

EXCLUDE_VCS=--exclude-vcs --exclude=.repo

DROID_BASE:=android-4.0.4_r1.1
KERNEL_BASE_COMMIT:=5e4fcd2c556e25e1b6787dcd0c97b06e29e42292
UBOOT_BASE_COMMIT:=b20a91d81fbdf9402df5425126bdee3368f10044

HEAD_MANIFEST:=head_manifest.default

.PHONY:pkgsrc
pkgsrc: output_dir get_source_for_pkg
	$(hide)echo "  save project list"
	$(hide)cd $(OUTPUT_DIR)/source && repo forall -c "echo -n \$$(pwd):;echo \$$REPO_PROJECT" > $(OUTPUT_DIR)/prjlist

	$(hide)echo "  remove internal source code..."
	$(hide)cd $(OUTPUT_DIR)/source && for prj in $(INTERNAL_PROJECTS); do rm -fr $$prj; done
	$(hide)echo "  package all source code..."
	$(hide)cd $(OUTPUT_DIR) && tar czf droid_all_src.tgz $(EXCLUDE_VCS) source/

	$(hide)echo "  package kernel source code..."
	$(hide)cd $(OUTPUT_DIR) && $(TOP_DIR)/core/gen_kernel_src_patch.sh $(KERNEL_BASE_COMMIT)

	$(hide)echo "  package uboot obm source code..."
	$(hide)cd $(OUTPUT_DIR) && $(TOP_DIR)/core/gen_uboot_obm_src_patch.sh $(UBOOT_BASE_COMMIT)

	$(hide)echo "  package android source code...,$(ANDROID_VERSION) $(BOARD) "
	$(hide)cd $(OUTPUT_DIR) && $(TOP_DIR)/core/gen_droid_src_patch.sh $(DROID_BASE) $(TOP_DIR)/core

	$(hide)cp $(TOP_DIR)/core/setup_android.sh $(OUTPUT_DIR)
	$(hide)cp $(BOARD)/release_package_list $(OUTPUT_DIR)/

#format: <file name>:[m|o]:[md5]
#m:means mandatory
#o:means optional
#md5: need to generate md5 sum
PUBLISHING_FILES+=droid_all_src.tgz:o:md5
PUBLISHING_FILES+=android_src.tgz:m:md5
PUBLISHING_FILES+=android_patches.tgz:m:md5
PUBLISHING_FILES+=kernel_src.tgz:m:md5
PUBLISHING_FILES+=kernel_patches.tgz:m:md5
PUBLISHING_FILES+=uboot_src.tgz:m:md5
PUBLISHING_FILES+=uboot_patches.tgz:m:md5
PUBLISHING_FILES+=obm_src.tgz:m:md5
PUBLISHING_FILES+=marvell_manifest.xml:m
PUBLISHING_FILES+=setup_android.sh:m
PUBLISHING_FILES+=release_package_list:o



