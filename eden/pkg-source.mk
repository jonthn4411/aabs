EXCLUDE_VCS=--exclude-vcs --exclude=.repo

KERNEL_2_6_32_BASE_COMMIT:=f6320db51173e3b94f54b87944b88d3b363c4487
KERNEL_2_6_35_BASE_COMMIT:=6631e089ef3dc4be98e78aafaca11047e7edf193
KERNEL_3_0_BASE_COMMIT:= 5e4fcd2c556e25e1b6787dcd0c97b06e29e42292
KERNEL_3_4_BASE_COMMIT:= a636fc98b8e21a2360186eec9871337a87142758

UBOOT_2009RC1_BASE_COMMIT:=aced78d852d0b009e8aaa1445af8cb40861ee549
UBOOT_201009_BASE_COMMIT:=1a2d9b30e31e2b7ed0acb64bfb2290911e3c9efb
UBOOT_201109_BASE_COMMIT:=1d5e7fb403257d62f0f2419cb83fdf6b0f02f215

HEAD_MANIFEST:=head_manifest.default

ifeq ($(ANDROID_VERSION),donut)
	DROID_BASE:=shgit/donut-release
else
ifeq ($(ANDROID_VERSION),eclair)
	DROID_BASE:=android-2.1_r2
else
ifeq ($(ANDROID_VERSION),froyo)
	DROID_BASE:=android-2.2.2_r1
else
ifeq ($(ANDROID_VERSION),gingerbread)
	DROID_BASE:=android-2.3.7_r1
else
ifeq ($(ANDROID_VERSION),honeycomb)
	DROID_BASE:=shgit/honeycomb-mr2-release
	HEAD_MANIFEST:=head_manifest.hc
else
ifeq ($(ANDROID_VERSION),ics)
	DROID_BASE:=android-4.0.4_r1.1
else
ifeq ($(ANDROID_VERSION),jb)
	DROID_BASE:=android-4.1.2_r1
endif
endif
endif
endif
endif
endif
endif

#format: <file name>:[m|o]:[md5]
#m:means mandatory
#o:means optional
#md5: need to generate md5 sum
PUBLISHING_FILES2+=droid_all_src.tgz:src:o:md5
PUBLISHING_FILES2+=android_src.tgz:src:m:md5
PUBLISHING_FILES2+=android_patches.tgz:src:m:md5
PUBLISHING_FILES2+=kernel_src.tgz:src:m:md5
PUBLISHING_FILES2+=kernel_patches.tgz:src:m:md5
PUBLISHING_FILES2+=uboot_src.tgz:src:m:md5
PUBLISHING_FILES2+=uboot_patches.tgz:src:m:md5
PUBLISHING_FILES2+=obm_src.tgz:src:m:md5
PUBLISHING_FILES2+=marvell_manifest.xml:src:m
PUBLISHING_FILES2+=setup_android.sh:src:m
PUBLISHING_FILES2+=delta_patches.tgz:src:o
PUBLISHING_FILES2+=delta_patches.base:src:o

.PHONY:pkgsrc

KERNEL_BASE_COMMIT:=$(KERNEL_2_6_32_BASE_COMMIT)
UBOOT_BASE_COMMIT:=$(UBOOT_2009RC1_BASE_COMMIT)

ifeq ($(ANDROID_VERSION),gingerbread)
	>...KERNEL_BASE_COMMIT:=$(KERNEL_2_6_35_BASE_COMMIT)
>...UBOOT_BASE_COMMIT:=$(UBOOT_201009_BASE_COMMIT)
else
	ifeq ($(ANDROID_VERSION),honeycomb)
>...KERNEL_BASE_COMMIT:=$(KERNEL_2_6_35_BASE_COMMIT)
>...UBOOT_BASE_COMMIT:=$(UBOOT_201009_BASE_COMMIT)
else
	ifeq ($(ANDROID_VERSION),ics)
>...KERNEL_BASE_COMMIT:=$(KERNEL_3_0_BASE_COMMIT)
>...UBOOT_BASE_COMMIT:=$(UBOOT_201109_BASE_COMMIT)
else
	ifeq ($(ANDROID_VERSION),jb)
>...KERNEL_BASE_COMMIT:=$(KERNEL_3_4_BASE_COMMIT)
>...UBOOT_BASE_COMMIT:=$(UBOOT_201109_BASE_COMMIT)
endif
endif
endif
endif

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
