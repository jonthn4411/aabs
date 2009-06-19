
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
DEMO_MEDIA_DIR:=/autobuild/demomedia

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
	repo sync && \
	$(TOP_DIR)/pkgsrc.sh $(OUTPUT_DIR)
	$(log) "  done."

#generate the changelog from GIT commit history
changelog: 
	$(log) "generating changelogs ..."
	$(hide)./gen_chglog.sh $(OUTPUT_DIR) $(SRC_DIR) 
	$(log) "  done."

.PHONY: build_droid_code cp_droid_bin gen_droid_nfs
build_droid: build_droid_code cp_droid_bin gen_droid_nfs

cp_droid_bin:
	$(log) "copying android binaries to output dir:$(OUTPUT_DIR)..."
	$(hide)cp -p $(SRC_DIR)/out/target/product/$(DROID_PRODUCT)/system_ubi.img $(OUTPUT_DIR) && chmod a+r $(OUTPUT_DIR)/system_ubi.img && \
	cp -p $(SRC_DIR)/out/target/product/$(DROID_PRODUCT)/userdata_ubi.img $(OUTPUT_DIR) && chmod a+r $(OUTPUT_DIR)/userdata_ubi.img && \
	if [ -d $(OUTPUT_DIR)/root ]; then rm -fr $(OUTPUT_DIR)/root; fi && \
	if [ -d $(OUTPUT_DIR)/root_nfs ]; then rm -fr $(OUTPUT_DIR)/root_nfs; fi && \
	cp -p -r $(SRC_DIR)/out/target/product/$(DROID_PRODUCT)/root $(OUTPUT_DIR) && \
	mv $(OUTPUT_DIR)/root $(OUTPUT_DIR)/root_nfs && \
	cp -p -r $(SRC_DIR)/out/target/product/$(DROID_PRODUCT)/system $(OUTPUT_DIR)/root_nfs && \
	cp -p -r $(SRC_DIR)/out/target/product/$(DROID_PRODUCT)/root $(OUTPUT_DIR) && \
	if [ -d $(OUTPUT_DIR)/modules ]; then rm -fr $(OUTPUT_DIR)/modules; fi && \
	cp -p -r $(SRC_DIR)/out/target/product/$(DROID_PRODUCT)/system/lib/modules $(OUTPUT_DIR) && \
	cd $(OUTPUT_DIR) && tar czf modules.tgz modules/
	$(log) "  done."

gen_droid_nfs:
	$(log) "generating root file system for booting android from NFS."
	$(log) "  modifying root nfs folder..."
	$(hide)cd $(OUTPUT_DIR)/root_nfs && $(TOP_DIR)/twist_root_nfs.sh 
	$(log) "copy demo media files to /sdcard if there are demo media files..."
	$(hide)if [ -d "$(DEMO_MEDIA_DIR)" ]; then \
			mkdir -p $(OUTPUT_DIR)/root_nfs/sdcard && \
			cp $(DEMO_MEDIA_DIR)/* $(OUTPUT_DIR)/root_nfs/sdcard/ && \
			echo "  done."; \
		   else \
			echo "    !!!demo media is not found."; \
		   fi
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

cp_android_root_dir_mlc:
	$(log) "copying root directory from $(OUTPUT_DIR) ..."
	$(hide)if [ -d "$(KERNEL_SRC_DIR)/root" ]; then rm -fr $(KERNEL_SRC_DIR)/root; fi
	$(hide)cp -p -r $(OUTPUT_DIR)/root $(KERNEL_SRC_DIR)  && \
	cd $(KERNEL_SRC_DIR)/root && $(TOP_DIR)/update_root_for_mlc.sh && \
	cd $(KERNEL_SRC_DIR) && tar czf $(OUTPUT_DIR)/root_android_mlc.tgz root/ 

kernel_configs:=android:mlc:root android:nfs android:mmc 
kernel_configs+=mameo:mlc mameo:nfs mameo:mmc

define define-kernel-target
tw:=$$(subst :,  , $(1) )
os:=$$(word 1, $$(tw) )
storage:=$$(word 2, $$(tw) )
root:=$$(word 3, $$(tw) )
kernel_cfg:=$$(if $$(findstring mameo,$$(os)), pxa168_$$(storage)_defconfig, pxa168_$$(os)_$$(storage)_defconfig )
build_kernel_$$(os)_$$(storage): private_os:=$$(os)
build_kernel_$$(os)_$$(storage): private_storage:=$$(storage)
build_kernel_$$(os)_$$(storage): private_root:=$$(root)
build_kernel_$$(os)_$$(storage): private_kernel_cfg:=$$(kernel_cfg)
build_kernel_$$(os)_$$(storage): private_root:=$$(root)
build_kernel_$$(os)_$$(storage): output_dir $$(if $$(findstring root,$$(root)), cp_$$(os)_root_dir_$$(storage) ) 
	$$(log) "starting to build kernel for booting $$(private_os) from $$(private_storage) ..."
	$$(log) "    kernel_config: $$(private_kernel_cfg): ..."
	$$(hide)cd $$(KERNEL_SRC_DIR) && \
	export PATH=$$(KERNEL_TOOLCHAIN_DIR):$$$$PATH && \
	export ARCH=arm && \
	export CROSS_COMPILE=$$(KERNEL_TOOLCHAIN_PREFIX) && \
	make $$(private_kernel_cfg) && \
	make clean && make 
	$(hide)cp $$(KERNEL_SRC_DIR)/arch/arm/boot/zImage $$(OUTPUT_DIR)/zImage.$$(private_os).$$(private_storage) 
	$(log) "  done."

.PHONY: build_kernel_$$(os)_$$(storage)
build_kernel: build_kernel_$$(os)_$$(storage)
endef

$(foreach kc, $(kernel_configs), $(eval $(call define-kernel-target, $(kc) ) ) )

build_uboot:

.PHONY: publish_dir
publish_dir:
	$(hide)if [ -z "$(PUBLISH_DIR)" ]; then \
	  echo "Please specify export PUBLISH_DIR in shell environment."; \
	  exit 1; \
	fi
	$(hide)if [ ! -d "$(PUBLISH_DIR)" ]; then \
	    mkdir -p $(PUBLISH_DIR); \
	fi

#copy the file only if the file exists
define cpif
$(hide)if [ -f $1 ]; then cp $1 $2; fi
endef

.PHONY: publish_bin publish_src
publish: publish_droid_images publish_src publish_kernels publish_others

define define-kernel-publish-target
tw:=$$(subst :,  , $(1) )
os:=$$(word 1, $$(tw) )
storage:=$$(word 2, $$(tw) )
$(PUBLISH_DIR)/zImage.$$(os).$$(storage): $$(OUTPUT_DIR)/zImage.$$(os).$$(storage)
	@echo "copy file: $$< $$(OUTPUT_DIR)"
	@cp $$< $$@

publish_kernels: $(PUBLISH_DIR)/zImage.$$(os).$$(storage)
endef
$(foreach kc, $(kernel_configs), $(eval $(call define-kernel-publish-target, $(kc) ) ) )

publish_src: publish_dir
	$(log) "copy source code tarball to $(PUBLISH_DIR)..."
	$(hide)cp $(OUTPUT_DIR)/manifest.xml $(PUBLISH_DIR)
	$(call cpif, $(OUTPUT_DIR)/droid_src.tgz, $(PUBLISH_DIR)) 
	$(call cpif, $(OUTPUT_DIR)/kernel_src.tgz, $(PUBLISH_DIR))
	$(log) "  done."
	
publish_droid_images: publish_dir
	$(log) "copy droid images files to $(PUBLISH_DIR)..."
	$(hide)cp $(OUTPUT_DIR)/system_ubi.img $(PUBLISH_DIR)
	$(hide)cp $(OUTPUT_DIR)/userdata_ubi.img $(PUBLISH_DIR)

publish_others: publish_dir
	$(hide)cp $(OUTPUT_DIR)/root_android_mlc.tgz $(PUBLISH_DIR)
	$(hide)cp $(OUTPUT_DIR)/modules.tgz $(PUBLISH_DIR)
	$(hide)cp $(OUTPUT_DIR)/root_nfs.tgz $(PUBLISH_DIR)
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

