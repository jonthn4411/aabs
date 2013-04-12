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

UBOOT_2009RC1_BASE_COMMIT:=aced78d852d0b009e8aaa1445af8cb40861ee549
UBOOT_201009_BASE_COMMIT:=1a2d9b30e31e2b7ed0acb64bfb2290911e3c9efb
UBOOT_201109_BASE_COMMIT:=1d5e7fb403257d62f0f2419cb83fdf6b0f02f215

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
ifeq ($(ABS_DROID_BRANCH),jb4.2)
	KERNEL_BASE_COMMIT:=$(KERNEL_3_4_BASE_COMMIT)
	UBOOT_BASE_COMMIT:=$(UBOOT_201109_BASE_COMMIT)
	DROID_BASE:=android-4.2.1_r1
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

# Platform hook
-include $(ABS_SOC)/pkg-source.mk
endif

