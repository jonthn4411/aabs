
# Make sure that there are no spaces in the absolute path; the
# build system can't deal with them.
ifneq ($(words $(shell pwd)),1)
$(warning ************************************************************)
$(warning You are building in a directory whose absolute path contains)
$(warning a space character:)
$(warning $(space))
$(warning "$(shell pwd)")
$(warning $(space))
$(warning Please move your source tree to a path that does not contain)
$(warning any spaces.)
$(warning ************************************************************)
$(error Directory names containing spaces not supported)
endif

#buiding android requires this
SHELL := /bin/bash

DROID_PRODUCT:=avlite
DROID_TYPE:=release
DROID_VARIANT:=eng

GIT_SERVER:=sh-dt-4514.sh.marvell.com
GIT_ANDROID_ROOT:=$(GIT_SERVER)/git/android
GIT_MANIFEST:=$(GIT_ANDROID_ROOT)/platform/manifest.git
GIT_REPO:=$(GIT_ANDROID_ROOT)/tools/repo.git
MANIFEST_BRANCH:=avengers-cupcake

KERNEL_TOOLCHAIN_DIR:=/usr/local/arm-marvell-linux-gnueabi/bin
KERNEL_TOOLCHAIN_PREFIX:=arm-marvell-linux-gnueabi-
KERNEL_SRC_DIR:=kernel

UBOOT_TOOLCHAIN_DIR:=$(KERNEL_TOOLCHAIN_DIR)
hide:=@

SRC_DIR:=avengers
OUTPUT_DIR:=out
RELEASE_VERSION:=$(shell date +%Y-%m-%d)
PUBLISH_DIR:=/autobuild/android/$(RELEASE_VERSION)/avlite

current-time:=[$$(date "+%Y-%m-%d %H:%M:%S")]
log:=@echo $(current-time)

#
#convert the relative directory to absolute directory.
#
TOP_DIR:=$(shell pwd)
OUTPUT_DIR:=$(TOP_DIR)/$(OUTPUT_DIR)
SRC_DIR:=$(TOP_DIR)/$(SRC_DIR)
KERNEL_SRC_DIR:=$(SRC_DIR)/$(KERNEL_SRC_DIR)

#by default show the help
help:

.PHONY: all clean source manifest changelog pkgsrc build publish
all: source manifest changelog build 

build: build_droid build_kernel build_uboot 
.PHONY: build_droid build_kernel build_uboot

.PHONY: clean_src_dir clean_out_dir
clean: clean_src_dir clean_out_dir

clean_out_dir:
	$(log) "clean output directory..."
	$(hide)if [ -d "$(OUTPUT_DIR)" ]; then \
	    rm -fr $(OUTPUT_DIR); \
	fi;

clean_src_dir: 
	$(log) "clean source directory..."
	$(hide)if [ -d "$(SRC_DIR)" ]; then \
	    rm -fr $(SRC_DIR); \
	fi

.PHONY: output_dir
output_dir:
	$(hide)if [ ! -d "$(OUTPUT_DIR)" ]; then \
	    mkdir $(OUTPUT_DIR); \
        fi

#get source code from GIT by repo
source:
	$(hide)if [ ! -d "$(SRC_DIR)" ]; then \
	    mkdir $(SRC_DIR); \
	fi
	$(log) "starting get source code from GIT server:$(GIT_SERVER) ..."
	$(hide)cd $(SRC_DIR) && \
	repo init -u ssh://$(GIT_MANIFEST) -b $(MANIFEST_BRANCH) --repo-url ssh://$(GIT_REPO) && \
	repo sync
	$(log) "  done."

manifest: output_dir
	$(log) "saving manifest file..."
	$(hide)cd $(SRC_DIR) && repo manifest -r -o $(OUTPUT_DIR)/manifest.xml
#if an expection happened, repo doesn't exit with a non-zero value, we use below command to make sure the manifest.xml is generated.
	$(hide)ls $(OUTPUT_DIR)/manifest.xml > /dev/null

PKGSRC_EXCLUDE:=\.git

#make sure the last character of $(SRC_DIR) is not "/"
pkgsrc: output_dir
	$(log) "Package source code using the $(OUTPUT_DIR)/manifest.xml"
	#check if $(OUTPUT_DIR)/manifest.xml is generated already
	$(hide)[ -s $(OUTPUT_DIR)/manifest.xml ]
	$(hide)if [ ! -d "$(OUTPUT_DIR)/source" ]; then \
		mkdir $(OUTPUT_DIR)/source; \
	fi
	$(log) " getting source code using manifest.xml"
	$(hide)cd $(OUTPUT_DIR)/source && \
	repo init -u ssh://$(GIT_MANIFEST) -b $(MANIFEST_BRANCH) --repo-url ssh://$(GIT_REPO) && \
	cp $(OUTPUT_DIR)/manifest.xml $(OUTPUT_DIR)/source/.repo/ && \
	repo sync
	$(hide)cd $(OUTPUT_DIR) && \
	tar czf source.tgz --exclude=$(PKGSRC_EXCLUDE) source/
	$(log) "  done."

#generate the changelog from GIT commit history
changelog: 
	$(log) "generating changelogs ..."
	@echo -n > $(OUTPUT_DIR)/changelog.day && echo -n > $(OUTPUT_DIR)/changelog.week &&\
	echo -n > $(OUTPUT_DIR)/changelog.biweek && echo -n > $(OUTPUT_DIR)/changelog.month
	$(hide)cd $(SRC_DIR) && \
	repo forall -c "$(TOP_DIR)/gen_chglog.sh $(OUTPUT_DIR)"
	$(log) "  done."

.PHONY: build_droid_code cp_droid_bin gen_droid_nfs
build_droid: build_droid_code cp_droid_bin gen_droid_nfs

cp_droid_bin:
	$(log) "copying android binaries to output dir:$(OUTPUT_DIR)..."
	$(hide)cp -p $(SRC_DIR)/out/target/product/$(DROID_PRODUCT)/system.img $(OUTPUT_DIR)
	$(hide)cp -p $(SRC_DIR)/out/target/product/$(DROID_PRODUCT)/userdata.img $(OUTPUT_DIR)
	$(hide)if [ -d $(OUTPUT_DIR)/root ]; then rm -fr $(OUTPUT_DIR)/root; fi
	$(hide)if [ -d $(OUTPUT_DIR)/root_nfs ]; then rm -fr $(OUTPUT_DIR)/root_nfs; fi
	$(hide)cp -p -r $(SRC_DIR)/out/target/product/$(DROID_PRODUCT)/root $(OUTPUT_DIR) 
	$(hide)mv $(OUTPUT_DIR)/root $(OUTPUT_DIR)/root_nfs
	$(hide)cp -p -r $(SRC_DIR)/out/target/product/$(DROID_PRODUCT)/system $(OUTPUT_DIR)/root_nfs
	$(hide)cp -p -r $(SRC_DIR)/out/target/product/$(DROID_PRODUCT)/root $(OUTPUT_DIR)
	$(log) "  done."

gen_droid_nfs:
	$(log) "generating root file system for booting android from NFS."
	$(log) "  modifying init.rc..."
	$(hide)sed -in "/^[ tab]*mount yaffs2/ s/mount/#(for nfs)mount/" $(OUTPUT_DIR)/root_nfs/init.rc
	$(hide)sed -in "/^[ tab]*mount rootfs rootfs/ s/mount/#(for nfs)mount/" $(OUTPUT_DIR)/root_nfs/init.rc
	$(log) "  chmod a+r system/usr/keychars/*..."
	$(hide)chmod a+r $(OUTPUT_DIR)/root_nfs/system/usr/keychars/* 
	$(log) "  packaging the root_nfs.tgz..."
	$(hide)cd $(OUTPUT_DIR) && tar czf root_nfs.tgz root_nfs/
	$(log) "  done"

build_droid_code: output_dir
	$(log) "building android source code ..."
	$(hide)cd $(SRC_DIR) && \
	source ./build/envsetup.sh && \
	chooseproduct $(DROID_PRODUCT) && choosetype $(DROID_TYPE) && choosevariant $(DROID_VARIANT) && \
	make 
	$(log) "  done"

.PHONY: build_kernel_flash build_kernel_nfs build_kernel_mmc cp_root_dir 
build_kernel: build_kernel_flash build_kernel_mmc build_kernel_nfs  

cp_root_dir:
	$(log) "copying root directory from $(OUTPUT_DIR)..."
	$(hide)cp -p -r $(OUTPUT_DIR)/root $(KERNEL_SRC_DIR)

build_kernel_flash: output_dir cp_root_dir
	$(log) "starting to build kernel for booting android from flash..."
	$(hide)cd $(KERNEL_SRC_DIR) && \
	export PATH=$(KERNEL_TOOLCHAIN_DIR):$$PATH && \
	export ARCH=arm && \
	export CROSS_COMPILE=$(KERNEL_TOOLCHAIN_PREFIX) && \
	make pxa168_android_defconfig && \
	make 
	$(hide)cp $(KERNEL_SRC_DIR)/arch/arm/boot/zImage $(OUTPUT_DIR)/zImage 
	$(log) "  done."

build_kernel_nfs: output_dir
	$(log) "starting to build kernel for booting android from NFS..."
	$(hide)cd $(KERNEL_SRC_DIR) && \
	export PATH=$(KERNEL_TOOLCHAIN_DIR):$$PATH && \
	export ARCH=arm && \
	export CROSS_COMPILE=$(KERNEL_TOOLCHAIN_PREFIX) && \
	make pxa168_android_nfs_defconfig && \
	make 
	$(hide)cp $(KERNEL_SRC_DIR)/arch/arm/boot/zImage $(OUTPUT_DIR)/zImage.nfs
	$(log) "  done."

build_kernel_mmc: output_dir
	$(log) "starting to build kernel for booting android from SD card..."
	$(hide)cd $(KERNEL_SRC_DIR) && \
	export PATH=$(KERNEL_TOOLCHAIN_DIR):$$PATH && \
	export ARCH=arm && \
	export CROSS_COMPILE=$(KERNEL_TOOLCHAIN_PREFIX) && \
	make pxa168_android_mmc_defconfig && \
	make
	$(hide)cp $(KERNEL_SRC_DIR)/arch/arm/boot/zImage $(OUTPUT_DIR)/zImage.mmc
	$(log) "  done."

build_uboot:

.PHONY: publish_dir, get_publish_dir
publish_dir:
	$(hide)if [ ! -d "$(PUBLISH_DIR)" ]; then \
	    mkdir -p $(PUBLISH_DIR); \
	fi

get_publish_dir:
	@echo $(PUBLISH_DIR)

#copy the file only if the file exists
define cpif
$(hide)if [ -f $1 ]; then cp $1 $2; fi
endef

.PHONY: publish_bin publish_src
publish: publish_bin publish_src

publish_src: publish_dir
	$(log) "copy source code tarball to publish dir..."
	$(hide)cp $(OUTPUT_DIR)/manifest.xml $(PUBLISH_DIR)
	$(call cpif, $(OUTPUT_DIR)/source.tgz, $(PUBLISH_DIR)) 
	$(log) "  done."
	
publish_bin: publish_dir
	$(log) "copy binary files to publish dir..."
	$(hide)cp $(OUTPUT_DIR)/zImage $(PUBLISH_DIR) 
	$(hide)cp $(OUTPUT_DIR)/system.img $(PUBLISH_DIR)
	$(hide)cp $(OUTPUT_DIR)/userdata.img $(PUBLISH_DIR)
	$(hide)cp $(OUTPUT_DIR)/zImage.nfs $(PUBLISH_DIR)
	$(hide)cp $(OUTPUT_DIR)/root_nfs.tgz $(PUBLISH_DIR)
	$(hide)cp $(OUTPUT_DIR)/zImage.mmc $(PUBLISH_DIR)
	$(hide)cp $(OUTPUT_DIR)/changelog.day $(PUBLISH_DIR)
	$(hide)cp $(OUTPUT_DIR)/changelog.week $(PUBLISH_DIR)
	$(hide)cp $(OUTPUT_DIR)/changelog.biweek $(PUBLISH_DIR)
	$(hide)cp $(OUTPUT_DIR)/changelog.month $(PUBLISH_DIR)
	$(log) "  done."

.PHONY: help
help:
	@echo "-------"
	@echo "  Auto build system for Avengers-Lite product."
	@echo "--------"
	@echo "  Targets:"
	@echo "    source: get the source code from GIT and put it in $(SRC_DIR). "
	@echo "    changelog: generate the changelog from from GIT commit history. "
	@echo "    manifest: save the manifest file."
	@echo "    build: build the droid, kernel and uboot."
	@echo ""
	@echo "    all: source manifest changelog build publish." 
	@echo "    clean: remove all the files in output directory and remove all the source files."
	@echo "    publish: copy the final targets from output directory to publishing directory."
	@echo "    pkgsrc: using manifest.xml to get the source from GIT server and package it as a tarball."
	@echo "  Settings:"
	@echo "    Manifest Repository: $(GIT_MANIFEST)"
	@echo "    Manifest Branch: $(MANIFEST_BRANCH)"
	@echo "    Kernel Toolchain: $(KERNEL_TOOLCHAIN_DIR)"
	@echo "    UBoot Toolchain: $(UBOOT_TOOLCHAIN_DIR)"
	@echo "    Publish Directory: $(PUBLISH_DIR)"
	@echo " "

