include core/pkg-source.mk

INTERNAL_PROJECTS :=vendor/marvell/external/helix
INTERNAL_PROJECTS +=vendor/marvell/external/gps_sirf
INTERNAL_PROJECTS +=vendor/marvell/external/flash
INTERNAL_PROJECTS +=vendor/marvell/generic/apps/CmmbPlayer
INTERNAL_PROJECTS +=vendor/marvell/generic/apps/CmmbStack

EXCLUDE_VCS=--exclude-vcs --exclude=.repo

UBOOT_BASE_COMMIT:=1d5e7fb403257d62f0f2419cb83fdf6b0f02f215
ifeq ($(ANDROID_VERSION),eclair)
	KERNEL_BASE_COMMIT:=8e0ee43bc2c3e19db56a4adaa9a9b04ce885cd84
else
ifeq ($(ANDROID_VERSION),froyo)
	KERNEL_BASE_COMMIT:=f6320db51173e3b94f54b87944b88d3b363c4487
else
ifeq ($(ANDROID_VERSION),gingerbread)
	KERNEL_BASE_COMMIT:=49e8954d66ce9ccf75f951a5adb217209ae6f78f
else
ifeq ($(ANDROID_VERSION),honeycomb)
	KERNEL_BASE_COMMIT:=49e8954d66ce9ccf75f951a5adb217209ae6f78f
else
	KERNEL_BASE_COMMIT:=5e4fcd2c556e25e1b6787dcd0c97b06e29e42292
endif
endif
endif
endif

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
ifeq ($(ANDROID_VERSION),ics)
	DROID_BASE:=android-4.0.4_r1
else
ifeq ($(ANDROID_VERSION),jb)
	DROID_BASE:=android-4.1.1_r1
else
	DROID_BASE:=shgit/honeycomb-mr2-release
	HEAD_MANIFEST:=head_manifest.hc
endif
endif
endif
endif
endif
endif

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
	$(hide)cp $(BOARD)/ReleaseNotes-$(ANDROID_VERSION).txt $(OUTPUT_DIR)/ReleaseNotes.txt
	$(log) "  done."


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
PUBLISHING_FILES+=ReleaseNotes.txt:o



