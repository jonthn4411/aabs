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

EXCLUDE_VCS=--exclude-vcs --exclude=.repo

KERNEL_2_6_32_BASE_COMMIT:=f6320db51173e3b94f54b87944b88d3b363c4487
KERNEL_2_6_35_BASE_COMMIT:=6631e089ef3dc4be98e78aafaca11047e7edf193
KERNEL_3_0_BASE_COMMIT:= 5e4fcd2c556e25e1b6787dcd0c97b06e29e42292
KERNEL_3_4_BASE_COMMIT:= a636fc98b8e21a2360186eec9871337a87142758
KERNEL_3_10_BASE_COMMIT:= 4f2e83b220172881b1dbae8e5bffcf6d6cd4f641
KERNEL_3_14_BASE_COMMIT:= c0eb5f75d52aad1fa0258e1c940244ae4644f398

UBOOT_2009RC1_BASE_COMMIT:=aced78d852d0b009e8aaa1445af8cb40861ee549
UBOOT_201009_BASE_COMMIT:=1a2d9b30e31e2b7ed0acb64bfb2290911e3c9efb
UBOOT_201109_BASE_COMMIT:=1d5e7fb403257d62f0f2419cb83fdf6b0f02f215
UBOOT_201403_BASE_COMMIT:=b44bd2c73c4cfb6e3b9e7f8cf987e8e39aa74a0b

HEAD_MANIFEST:=head_manifest.default
KERNEL_BASE_COMMIT:=$(KERNEL_2_6_32_BASE_COMMIT)
UBOOT_BASE_COMMIT:=$(UBOOT_2009RC1_BASE_COMMIT)

ifeq ($(ABS_DROID_BRANCH),donut)
	DROID_BASE:=shgit/donut-release
else
ifeq ($(ABS_DROID_BRANCH),eclair)
	DROID_BASE:=android-2.1_r2
else
ifeq ($(ABS_DROID_BRANCH),froyo)
	DROID_BASE:=android-2.2.2_r1
else
ifeq ($(ABS_DROID_BRANCH),gingerbread)
	KERNEL_BASE_COMMIT:=$(KERNEL_2_6_35_BASE_COMMIT)
	UBOOT_BASE_COMMIT:=$(UBOOT_201009_BASE_COMMIT)
	DROID_BASE:=android-2.3.7_r1
else
ifeq ($(ABS_DROID_BRANCH),honeycomb)
	KERNEL_BASE_COMMIT:=$(KERNEL_2_6_35_BASE_COMMIT)
	UBOOT_BASE_COMMIT:=$(UBOOT_201009_BASE_COMMIT)
	DROID_BASE:=shgit/honeycomb-mr2-release
	HEAD_MANIFEST:=head_manifest.hc
else
ifeq ($(ABS_DROID_BRANCH),ics)
	KERNEL_BASE_COMMIT:=$(KERNEL_3_0_BASE_COMMIT)
	UBOOT_BASE_COMMIT:=$(UBOOT_201109_BASE_COMMIT)
	DROID_BASE:=android-4.0.4_r1.1
else
ifeq ($(ABS_DROID_BRANCH),jb)
	KERNEL_BASE_COMMIT:=$(KERNEL_3_4_BASE_COMMIT)
	UBOOT_BASE_COMMIT:=$(UBOOT_201109_BASE_COMMIT)
	DROID_BASE:=android-4.1.2_r1
else
ifeq ($(ABS_DROID_BRANCH),$(filter $(ABS_DROID_BRANCH), jb4.2 jb42))
	KERNEL_BASE_COMMIT:=$(KERNEL_3_4_BASE_COMMIT)
	UBOOT_BASE_COMMIT:=$(UBOOT_201109_BASE_COMMIT)
	DROID_BASE:=android-4.2.2_r1
else
ifeq ($(ABS_DROID_BRANCH),$(filter $(ABS_DROID_BRANCH), jb4.3 jb43))
	KERNEL_BASE_COMMIT:=$(KERNEL_3_4_BASE_COMMIT)
	UBOOT_BASE_COMMIT:=$(UBOOT_201109_BASE_COMMIT)
	DROID_BASE:=android-4.3_r2.1
else
ifeq ($(ABS_DROID_BRANCH),$(filter $(ABS_DROID_BRANCH), kk4.4 aosp pdk5.0 pdk5.0_32))
	KERNEL_BASE_COMMIT:=$(KERNEL_3_10_BASE_COMMIT)
	UBOOT_BASE_COMMIT:=$(UBOOT_201109_BASE_COMMIT)
	DROID_BASE:=android-4.4.3_r1.1
endif
ifeq ($(ABS_DROID_BRANCH),$(filter $(ABS_DROID_BRANCH), kk4.4 aosp pdk5.0 pdk5.0_32))
	KERNEL_BASE_COMMIT:=$(KERNEL_3_14_BASE_COMMIT)
	UBOOT_BASE_COMMIT:=$(UBOOT_201403_BASE_COMMIT)
	DROID_BASE:=android-4.4.3_r1.1
endif
endif
endif
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

.PHONY:pkgsrc
save_prjlist: get_source_for_pkg
	$(hide)echo "  save project list"
	$(hide)cd $(OUTPUT_DIR)/source && repo forall -c "echo -n \$$(pwd):;echo \$$REPO_PROJECT" > $(OUTPUT_DIR)/prjlist

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

PUBLISHING_FILES2+=delta_patches.tgz:src:o
PUBLISHING_FILES2+=delta_patches.base:src:o

publish_setup_sh: output_dir
	$(hide)cp $(ABS_TOP_DIR)/core/setup_android.sh $(OUTPUT_DIR)

publish_RN:
	$(hide)cp $(ABS_SOC)/$(ANDROID_VERSION)_RN.pdf $(OUTPUT_DIR)

PUBLISHING_FILES+=$(ANDROID_VERSION)_RN.pdf:o

# Platform hook
-include $(ABS_SOC)/pkg-source.mk
endif

