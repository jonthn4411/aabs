
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

SRC_DIR:=avengers
OUTPUT_DIR:=out
DEMO_MEDIA_DIR:=/autobuild/demomedia

current-time:=[$$(date "+%Y-%m-%d %H:%M:%S")]
log:=@echo $(current-time)
hide:=@
space:= #a designated space

KERNEL_SRC_DIR:=kernel
UBOOT_SRC_DIR:=boot/uboot
UBOOT_CONFIG:=avengers_config
PUBLISHING_FILES:=
#
#convert the relative directory to absolute directory.
#
TOP_DIR:=$(shell pwd)
OUTPUT_DIR:=$(TOP_DIR)/$(OUTPUT_DIR)
SRC_DIR:=$(TOP_DIR)/$(SRC_DIR)
KERNEL_SRC_DIR:=$(SRC_DIR)/$(KERNEL_SRC_DIR)
UBOOT_SRC_DIR:=$(SRC_DIR)/$(UBOOT_SRC_DIR)

#default android tool
DEFAULT_CCACHE:=$(SRC_DIR)/prebuilt/linux-x86/ccache/ccache
DEFAULT_ANDROID_TOOLCHAIN:=$(SRC_DIR)/prebuilt/linux-x86/toolchain/arm-eabi-4.2.1/bin/arm-eabi-

#use the Android toolchain by default
ifeq ($(strip $(EXTERNAL_TOOLCHAIN_PREFIX)),)
    KERNEL_TOOLCHAIN_PREFIX:=$(DEFAULT_ANDROID_TOOLCHAIN)
else
    #make Android use external toolchain
    export TARGET_TOOLS_PREFIX:=$(EXTERNAL_TOOLCHAIN_PREFIX)
    KERNEL_TOOLCHAIN_PREFIX:=$(EXTERNAL_TOOLCHAIN_PREFIX)
endif

ifneq ($(strip $(USE_CCACHE) ), )
    #enable android build system to use ccache
    export USE_CCACHE:=true
    KERNEL_TOOLCHAIN_PREFIX:=$(DEFAULT_CCACHE) $(KERNEL_TOOLCHAIN_PREFIX)
endif

#by default show the help
help:

.PHONY: all clean source changelog pkgsrc build publish
all: changelog build 

#we need first build the android, so we get the root dir 
# and then we build the kernel images with the root dir and get the package of corresponding modules
# and then we use those module package to build corresponding android package.
build: build_droid_root build_kernel build_droid_pkgs build_uboot build_obm
.PHONY: build_droid_root build_kernel build_droid_pkgs build_uboot build_obm

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
source: output_dir
	$(hide)if [ ! -d "$(SRC_DIR)" ]; then \
	    mkdir $(SRC_DIR); \
	fi
	$(log) "starting get source code from GIT server:$(GIT_SERVER) ..."
	$(hide)cd $(SRC_DIR) && \
	repo init -u ssh://$(GIT_MANIFEST) -b $(MANIFEST_BRANCH) --repo-url ssh://$(GIT_REPO) && \
	repo sync
	$(log) "saving manifest file..."
	$(hide)cd $(SRC_DIR) && repo manifest -r -o $(OUTPUT_DIR)/manifest.xml
#if an expection happened, repo doesn't exit with a non-zero value, we use below command to make sure the manifest.xml is generated.
	$(hide)ls $(OUTPUT_DIR)/manifest.xml > /dev/null
	$(log) "  done."

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
	cp $(OUTPUT_DIR)/manifest.xml $(OUTPUT_DIR)/source/.repo/manifests/autobuild.xml && \
	repo init -m autobuild.xml && \
	repo sync && \
	$(TOP_DIR)/pkgsrc.sh $(OUTPUT_DIR)
	$(log) "  done."

#generate the changelog from GIT commit history
changelog: 
	$(log) "generating changelogs ..."
	$(hide)./gen_chglog.sh $(OUTPUT_DIR) $(SRC_DIR) 
	$(log) "  done."

build_droid_root: output_dir
	$(log) "building android source code ..."
	$(hide)cd $(SRC_DIR) && \
	source ./build/envsetup.sh && \
	chooseproduct $(DROID_PRODUCT) && choosetype $(DROID_TYPE) && choosevariant $(DROID_VARIANT) && \
	ANDROID_KERNEL_CONFIG=no_kernel_modules make && \
	if [ -d $(OUTPUT_DIR)/root ]; then rm -fr $(OUTPUT_DIR)/root; fi && \
	echo "  copy root directory ..." && \
	cp -p -r $(SRC_DIR)/out/target/product/$(DROID_PRODUCT)/root $(OUTPUT_DIR) 
	$(log) "  done"

build_droid_pkgs: build_droid_with_helix build_droid_without_helix
.PHONY: build_droid_with_helix build_droid_without_helix

build_droid_with_helix: rebuild_droid_helix_enabled package_droid_mlc_helix package_droid_mmc_helix
build_droid_without_helix: rebuild_droid_helix_disabled package_droid_mlc_nohelix package_droid_mmc_nohelix

define rebuild-droid-helix-config
.PHONY:rebuild_droid_helix_$(1)

#we only rebuild a certain files that affect helix player to speed up the build process.
#files to remove: TARGET_OUT/system/lib/helix/*
#		TARGET_OUT/*.img
#		limmediaplayerservice
rebuild_droid_helix_$(1): helix_config:=$$(if $$(findstring $(1),enabled),true,false)
rebuild_droid_helix_$(1):
	$$(log) "rebuild android with helix:$(1)..."
	$$(hide)cd $(SRC_DIR)/vendor/marvell/$$(DROID_PRODUCT) && \
	sed -i "/^[ tab]*BOARD_ENABLE_HELIX[ tab]*:=/ s/:=.*/:= $$(helix_config)/" BoardConfig.mk
	$$(hide)cd $$(SRC_DIR) && \
	source ./build/envsetup.sh && \
	chooseproduct $$(DROID_PRODUCT) && choosetype $$(DROID_TYPE) && choosevariant $$(DROID_VARIANT) && \
	rm -f out/target/product/$$(DROID_PRODUCT)/*.img && \
	rm -fr out/target/product/$$(DROID_PRODUCT)/system/lib/helix && \
	rm -fr out/target/product/$$(DROID_PRODUCT)/obj/SHARED_LIBRARIES/libmediaplayerservice_intermediates/ && \
	ANDROID_KERNEL_CONFIG=no_kernel_modules make
	$$(log) "  done for rebuild_droid_helix_$(1)"
endef

$(eval $(call rebuild-droid-helix-config,enabled) )
$(eval $(call rebuild-droid-helix-config,disabled) )

define package-droid-mlc-config
.PHONY:package_droid_mlc_$(1)
package_droid_mlc_$(1):
	$$(log) "package file system for booting android from MLC for $(1)..."
	$$(log) "  updating the modules..."
	$$(hide)if [ -d $$(OUTPUT_DIR)/modules ]; then rm -fr $$(OUTPUT_DIR)/modules; fi
	$$(hide)cd $$(OUTPUT_DIR) && tar xzf modules_android_mlc.tgz
	$$(hide)export ANDROID_PREBUILT_MODULES=$$(OUTPUT_DIR)/modules && \
	cd $$(SRC_DIR) && \
	source ./build/envsetup.sh && \
	chooseproduct $$(DROID_PRODUCT) && choosetype $$(DROID_TYPE) && choosevariant $$(DROID_VARIANT) && \
	make && \
	echo "    copy UBI image files..." && \
	cp -p $(SRC_DIR)/out/target/product/$$(DROID_PRODUCT)/system_ubi.img $$(OUTPUT_DIR)/system_ubi_$(1).img && \
	cp -p $(SRC_DIR)/out/target/product/$$(DROID_PRODUCT)/userdata_ubi.img $$(OUTPUT_DIR)/userdata_ubi_$(1).img 
	$$(log) "  done for package_droid_mlc_$(1)."

PUBLISHING_FILES+=system_ubi_$(1).img:m:md5 
PUBLISHING_FILES+=userdata_ubi_$(1).img:m:md5 
endef
$(eval $(call package-droid-mlc-config,helix) )
$(eval $(call package-droid-mlc-config,nohelix) )

define package-droid-mmc-config
.PHONY: package_droid_mmc_$(1)
package_droid_mmc_$(1):
	$$(log) "package root file system for booting android from SD card or NFS for $(1)."
	$$(hide)if [ -d $$(OUTPUT_DIR)/root_nfs ]; then rm -fr $$(OUTPUT_DIR)/root_nfs; fi
	$$(hide)cp -r -p $$(OUTPUT_DIR)/root $$(OUTPUT_DIR)/root_nfs && \
	cp -p -r $$(SRC_DIR)/out/target/product/$$(DROID_PRODUCT)/system $$(OUTPUT_DIR)/root_nfs
	$$(log) "  updating the modules..."
	$$(hide)if [ -d $$(OUTPUT_DIR)/modules ]; then rm -fr $$(OUTPUT_DIR)/modules; fi
	$$(hide)cd $$(OUTPUT_DIR) && tar xzf modules_android_mmc.tgz && cp -r modules $$(OUTPUT_DIR)/root_nfs/system/lib/
	$$(log) "  modifying root nfs folder..."
	$$(hide)cd $$(OUTPUT_DIR)/root_nfs && $$(TOP_DIR)/twist_root_nfs.sh 
	$$(log) "copy demo media files to /sdcard if there are demo media files..."
	$$(hide)if [ -d "$$(DEMO_MEDIA_DIR)" ]; then \
			mkdir -p $$(OUTPUT_DIR)/root_nfs/sdcard && \
			cp $$(DEMO_MEDIA_DIR)/* $$(OUTPUT_DIR)/root_nfs/sdcard/ && \
			echo "  done."; \
		   else \
			echo "    !!!demo media is not found."; \
		   fi
	$$(log) "  packaging the root_nfs.tgz..."
	$$(hide)cd $$(OUTPUT_DIR) && tar czf root_nfs_$(1).tgz root_nfs/
	$$(log) "  done for package_droid_mmc_$(1)."

PUBLISHING_FILES+=root_nfs_$(1).tgz:m:md5 
endef
$(eval $(call package-droid-mmc-config,helix) )
$(eval $(call package-droid-mmc-config,nohelix) )

cp_android_root_dir_mlc:
	$(log) "copying root directory from $(OUTPUT_DIR) ..."
	$(hide)if [ -d "$(KERNEL_SRC_DIR)/root" ]; then rm -fr $(KERNEL_SRC_DIR)/root; fi
	$(hide)cp -p -r $(OUTPUT_DIR)/root $(KERNEL_SRC_DIR)  && \
	cd $(KERNEL_SRC_DIR)/root && $(TOP_DIR)/update_root_for_mlc.sh && \
	cd $(KERNEL_SRC_DIR) && tar czf $(OUTPUT_DIR)/root_android_mlc.tgz root/ 

kernel_configs:=android:mlc:root android:mmc 
kernel_configs+=maemo:mlc

module_files:=$(KERNEL_SRC_DIR)/drivers/net/wireless/libertas/libertas.ko \
	$(KERNEL_SRC_DIR)/drivers/net/wireless/libertas/libertas_sdio.ko

GC300_SRC_DIR:=$(SRC_DIR)/gc300_driver
module_files+=$(GC300_SRC_DIR)/build/sdk/drivers/galcore.ko

define define-kernel-target
tw:=$$(subst :,  , $(1) )
os:=$$(word 1, $$(tw) )
storage:=$$(word 2, $$(tw) )
root:=$$(word 3, $$(tw) )
kernel_cfg:=$$(if $$(findstring maemo,$$(os)), pxa168_$$(storage)_defconfig, pxa168_$$(os)_$$(storage)_defconfig )
build_kernel_$$(os)_$$(storage): private_os:=$$(os)
build_kernel_$$(os)_$$(storage): private_storage:=$$(storage)
build_kernel_$$(os)_$$(storage): private_root:=$$(root)
build_kernel_$$(os)_$$(storage): private_kernel_cfg:=$$(kernel_cfg)
build_kernel_$$(os)_$$(storage): private_root:=$$(root)
build_kernel_$$(os)_$$(storage): output_dir $$(if $$(findstring root,$$(root)), cp_$$(os)_root_dir_$$(storage) ) 
	$$(log) "starting to build kernel for booting $$(private_os) from $$(private_storage) ..."
	$$(log) "    kernel_config: $$(private_kernel_cfg): ..."
	$$(hide)cd $$(KERNEL_SRC_DIR) && \
	export ARCH=arm && \
	export CROSS_COMPILE="$$(KERNEL_TOOLCHAIN_PREFIX)" && \
	make $$(private_kernel_cfg) && \
	make clean && make 
	$$(hide)cp $$(KERNEL_SRC_DIR)/arch/arm/boot/zImage $$(OUTPUT_DIR)/zImage.$$(private_os).$$(private_storage) 
	$$(log) "    building gc300 driver..."
	$$(hide)export KERNEL_DIR=$$(KERNEL_SRC_DIR) && export CROSS_COMPILE="$$(KERNEL_TOOLCHAIN_PREFIX)" && \
	cd $$(GC300_SRC_DIR) && make avlite
	$$(log) "    copy module files ..."
	$$(hide)if [ -d $$(OUTPUT_DIR)/modules ]; then rm -fr $$(OUTPUT_DIR)/modules; fi && mkdir $$(OUTPUT_DIR)/modules
	$$(hide)for mod in $$(module_files); do cp $$$$mod $$(OUTPUT_DIR)/modules; done
	$$(hide)cd $$(OUTPUT_DIR) && tar czf modules_$$(private_os)_$$(private_storage).tgz modules/ 
	$(log) "  done."

.PHONY: build_kernel_$$(os)_$$(storage)
build_kernel: build_kernel_$$(os)_$$(storage)
endef

$(foreach kc, $(kernel_configs), $(eval $(call define-kernel-target, $(kc) ) ) )

#build uboot
build_uboot:
	$(log) "starting to build uboot"
	$(hide)cd $(UBOOT_SRC_DIR) && \
	export ARCH=arm && \
	export CROSS_COMPILE="$(KERNEL_TOOLCHAIN_PREFIX)" && \
	make $(UBOOT_CONFIG) && \
	make 
	$(hide)cp $(UBOOT_SRC_DIR)/u-boot.bin $(OUTPUT_DIR)/
	$(log) "  done."

#build obm
OBM_NTIM:=ntim_obm_uboot_aspen_nand.bin
OBM_NTLOADER:=ASPEN_NTLOADER.bin
build_obm:
	$(log) "start to copy obm files"
	@cp $(SRC_DIR)/boot/obm/binaries/BootLoader/$(OBM_NTIM) $(OUTPUT_DIR)
	@cp $(SRC_DIR)/boot/obm/binaries/BootLoader/$(OBM_NTLOADER) $(OUTPUT_DIR)
	$(log) "  done."

MD5_FILE:=checksums.md5

#format: <file name>:[m|o]:[md5]
#m:means mandatory
#o:means optional
#md5: need to generate md5 sum
PUBLISHING_FILES+=manifest.xml:m\
	kernel_src.tgz:o:md5 \
	droid_src.tgz:o:md5 \
	gc300_driver_src.tgz:o:md5

PUBLISHING_FILES+=root_android_mlc.tgz:m:md5 

PUBLISHING_FILES+=changelog.day:m \
	changelog.week:m \
	changelog.biweek:m \
	changelog.month:m 

PUBLISHING_FILES+=u-boot.bin:m:md5 \
	boot_src.tgz:o:md5

PUBLISHING_FILES+=$(OBM_NTIM):m:md5 \
	$(OBM_NTLOADER):m:md5

define define-kernel-publishing-file
tw:=$$(subst :,  , $(1) )
os:=$$(word 1, $$(tw) )
storage:=$$(word 2, $$(tw) )
PUBLISHING_FILES+=zImage.$$(os).$$(storage):m:md5
PUBLISHING_FILES+=modules_$$(os)_$$(storage).tgz:m:md5
endef

$(foreach kc, $(kernel_configs), $(eval $(call define-kernel-publishing-file, $(kc) ) ) )

define cp-with-md5
	@echo "publishing mandatory file:$(2)"
	@cp $(1) $(2) && chmod a+r $(2)
	$(if $(findstring $(strip $(3)),md5), \
		@echo "generating md5 for $(2)" && \
		cd $(dir $(1)) && \
		md5sum $(notdir $(1)) >>$(OUTPUT_DIR)/$(MD5_FILE) \
	 )
endef

define cpif-with-md5
	@if [ -f $(1) ]; then echo "publishing optional file:$(2)"; cp $(1) $(2) && chmod a+r $(2); fi
	$(if $(findstring $(strip $(3)),md5), \
		@if [ -f $1 ]; then echo "generating md5 for $(2)"; \
		cd $(dir $(1)) && \
		md5sum $(notdir $(1)) >>$(OUTPUT_DIR)/$(MD5_FILE); fi\
	 )
endef

define define-publishing-file-target
tw:=$$(subst :,  , $(1) )
name:=$$(word 1, $$(tw) )
mandatory:=$$(word 2, $$(tw) )
md5:=$$(word 3, $$(tw) )

.PHONY: publish_$$(name)

publish_$$(name): private_name:=$$(name)
publish_$$(name): private_mandatory:=$$(mandatory)
publish_$$(name): private_md5:=$$(md5)
publish_$$(name): 
	$$(if $$(findstring $$(strip $$(private_mandatory)),m), \
	$$(call cp-with-md5, $$(OUTPUT_DIR)/$$(private_name), $$(PUBLISH_DIR)/$$(private_name), $$(private_md5) ), \
	$$(call cpif-with-md5, $$(OUTPUT_DIR)/$$(private_name), $$(PUBLISH_DIR)/$$(private_name), $$(private_md5) ) )

publish: publish_$$(name)
endef

.PHONY: publish_dir
publish_dir:
	$(hide)if [ -z "$(PUBLISH_DIR)" ]; then \
	  echo "Please specify export PUBLISH_DIR in shell environment."; \
	  exit 1; \
	fi
	$(hide)if [ ! -d "$(PUBLISH_DIR)" ]; then \
	    mkdir -p $(PUBLISH_DIR); \
	fi

clean_md5_file:
	@echo -n > $(OUTPUT_DIR)/$(MD5_FILE)

publish: publish_dir clean_md5_file
	@echo "Publish $(MD5_FILE)"
	@cp $(OUTPUT_DIR)/$(MD5_FILE) $(PUBLISH_DIR)

$(foreach pf, $(PUBLISHING_FILES), $(eval $(call define-publishing-file-target, $(pf) ) ) )

.PHONY: help
help:
	@echo "-------"
	@echo "  Auto build system for Avengers-Lite product."
	@echo "--------"
	@echo "  Targets:"
	@echo "    source: get the source code from GIT and put it in $(SRC_DIR). and save the manifest file."
	@echo "    changelog: generate the changelog from from GIT commit history. "
	@echo "    manifest: save the manifest file."
	@echo "    build: build the droid, kernel and uboot."
	@echo ""
	@echo "    all: changelog build" 
	@echo "    clean: remove all the files in output directory and remove all the source files."
	@echo "    publish: copy the final targets from output directory to publishing directory."
	@echo "    pkgsrc: using manifest.xml to get the source from GIT server and package it as a tarball."
	@echo "  Settings:"
	@echo "    Manifest Repository: $(GIT_MANIFEST)"
	@echo "    Manifest Branch: $(MANIFEST_BRANCH)"
	@echo "    Kernel Toolchain: $(KERNEL_TOOLCHAIN_PREFIX)"
	@echo "    Output Directory: $(OUTPUT_DIR)"
	@echo "    Source Directory: $(SRC_DIR)"
	@echo "    Publish Directory: $(PUBLISH_DIR)"
	@echo " "

