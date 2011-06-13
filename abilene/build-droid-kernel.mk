#check if the required variables have been set.
#$(call check-variables,BUILD_VARIANTS)

DEMO_MEDIA_DIR:=/autobuild/demomedia
MY_SCRIPT_DIR:=$(TOP_DIR)/abilene

DROID_PRODUCT:=abilene
DROID_TYPE:=release

KERNELSRC_TOPDIR:=kernel

.PHONY:clean_droid_kernel
clean_droid_kernel: clean_droid clean_kernel

.PHONY:clean_droid
clean_droid:
	$(log) "clean android ..."
	$(hide)cd $(SRC_DIR) && \
	source ./build/envsetup.sh &&
	chooseproduct $(DROID_PRODUCT) && choosetype $(DROID_TYPE) && choosevariant $(DROID_VARIANT) && \
	make clean
	$(log) "    done"

.PHONY:clean_kernel
clean_kernel:
	$(log) "clean kernel ..."
	$(hide)cd $(SRC_DIR)/$(KERNELSRC_TOPDIR) && make clean
	$(log) "    done"

# we first build the whole android and then we can do incremental build to save time.

#$1:build variant
define define-build-droid-kernel
.PHONY:build_droid_kernel_$(1)
build_droid_kernel_$(1): build_droid_root_$(1) build_kernel_$(1) build_droid_pkgs_$(1) 
endef

#$1:build variant
define define-build-droid-root
.PHONY: build_droid_root_$(1) 
build_droid_root_$(1): output_dir
	$$(log) "[$(1)]building android source code ..."
	$$(hide)cd $$(SRC_DIR) && \
	source ./build/envsetup.sh && \
	chooseproduct $$(DROID_PRODUCT) && choosetype $$(DROID_TYPE) && choosevariant $$(DROID_VARIANT) && \
	ANDROID_PREBUILT_MODULES=no_kernel_modules make -j$$(MAKE_JOBS) 
	$(log) "  done"

endef

#$1:build variant
define define-build-droid-pkgs
.PHONY:build_droid_pkgs_$(1)
build_droid_pkgs_$(1): 
endef

#$1: build variant
#$2: internal or external
define define-build-droid-config
.PHONY: build_droid_$(2)_$(1) 
build_droid_$(2)_$(1): rebuild_droid_$(2)_$(1) package_droid_mlc_$(2)_$(1) package_droid_mmc_$(2)_$(1)
	$$(log) "build_droid_$(2)_$(1) is done, reseting the source code."
	$$(hide)cd $$(SRC_DIR)/vendor/marvell/$$(DROID_PRODUCT)/ &&\
	git reset --hard
	$$(log) "  done"

build_droid_pkgs_$(1): build_droid_$(2)_$(1)
endef

#$1:internal or external
#$2:build variant
define rebuild-droid-config
.PHONY:rebuild_droid_$(1)_$(2)

#for external build, we should remove helix and adobe flash libraries.
rebuild_droid_$(1)_$(2): nolib_config:=$$(if $$(findstring $(1),external),true,false)
rebuild_droid_$(1)_$(2):
	$$(log) "[$(2)]rebuild android for $(1)..."
	$$(hide)cd $$(SRC_DIR)/vendor/marvell/$$(DROID_PRODUCT) && \
	sed -i "/^[ tab]*BOARD_NO_HELIX_LIBS[ tab]*:=/ s/:=.*/:= $$(nolib_config)/" BoardConfig.mk && \
	sed -i "/^[ tab]*BOARD_NO_FLASH_PLUGIN[ tab]*:=/ s/:=.*/:= $$(nolib_config)/" BoardConfig.mk
	$$(hide)rm -fr $$(SRC_DIR)/out/target/product/$$(DROID_PRODUCT)/system/lib/helix
	$$(hide)rm -f $$(SRC_DIR)/out/target/product/$$(DROID_PRODUCT)/system/lib/netscape/libflashplayer.so
	$$(hide)rm -f $$(SRC_DIR)/out/target/product/$$(DROID_PRODUCT)/*.img
	$$(hide)cd $$(SRC_DIR) && \
	source ./build/envsetup.sh && \
	chooseproduct $$(DROID_PRODUCT) && choosetype $$(DROID_TYPE) && choosevariant $$(DROID_VARIANT) && \
	ANDROID_PREBUILT_MODULES=no_kernel_modules make -j$$(MAKE_JOBS)
	$$(log) "    packaging helix libraries and flash library..."
	$$(hide)if [ "$(1)" == "internal" ]; then \
	cd $$(SRC_DIR)/out/target/product/$$(DROID_PRODUCT)/system/lib &&\
	mkdir -p helix &&\
	tar czf $$(OUTPUT_DIR)/$(2)/helix.tgz helix/ && \
	mkdir -p netscape &&\
	tar czf $$(OUTPUT_DIR)/$(2)/flash.tgz netscape/; \
	fi
	$$(log) "  done for rebuild_droid_$(1)_$(2)"

ifeq ($(1),internal)
PUBLISHING_FILES_$(2)+=$(2)/helix.tgz:m:md5
PUBLISHING_FILES_$(2)+=$(2)/flash.tgz:m:md5
endif
endef

#$1:internal or external
#$2:build variant
define package-droid-mlc-config
.PHONY:package_droid_mlc_$(1)_$(2)
package_droid_mlc_$(1)_$(2):
	$$(log) "[$(2)]package file system for booting android from MLC for $(1)..."
	$$(log) "  updating the modules..."
	$$(hide)if [ -d $$(OUTPUT_DIR)/$(2)/modules ]; then rm -fr $$(OUTPUT_DIR)/$(2)/modules; fi
	$$(hide)mkdir -p $$(OUTPUT_DIR)/$(2)
	$$(hide)cd $$(OUTPUT_DIR)/$(2) && tar xzf modules_android_mmc.tgz
	$$(hide)export ANDROID_PREBUILT_MODULES=$$(OUTPUT_DIR)/$(2)/modules && \
	cd $$(SRC_DIR) && \
	source ./build/envsetup.sh && \
	chooseproduct $$(DROID_PRODUCT) && choosetype $$(DROID_TYPE) && choosevariant $$(DROID_VARIANT) && \
	make -j$$(MAKE_JOBS) && \
	echo "    copy ext4 image files..." && \
	cp -p $(SRC_DIR)/out/target/product/$$(DROID_PRODUCT)/mbr $$(OUTPUT_DIR)/$(2)/mbr && \
	cp -p $(SRC_DIR)/out/target/product/$$(DROID_PRODUCT)/primary_gpt_8g $$(OUTPUT_DIR)/$(2)/primary_gpt_8g && \
	cp -p $(SRC_DIR)/out/target/product/$$(DROID_PRODUCT)/secondary_gpt_8g $$(OUTPUT_DIR)/$(2)/secondary_gpt_8g && \
	cp -p $(SRC_DIR)/out/target/product/$$(DROID_PRODUCT)/ramdisk_ext3.img $$(OUTPUT_DIR)/$(2)/ramdisk_ext3.img && \
	cp -p $(SRC_DIR)/out/target/product/$$(DROID_PRODUCT)/system_ext3.img $$(OUTPUT_DIR)/$(2)/system_ext3_$(1).img && \
	cp -p $(SRC_DIR)/out/target/product/$$(DROID_PRODUCT)/userdata_ext3.img $$(OUTPUT_DIR)/$(2)/userdata_ext3_$(1).img
	$$(log) "  done for package_droid_mlc_$(1)$(2)."

ifeq ($(1),internal)
PUBLISHING_FILES_$(2)+=$(2)/mbr:m:md5
PUBLISHING_FILES_$(2)+=$(2)/ramdisk_ext3.img:m:md5
endif
PUBLISHING_FILES_$(2)+=$(2)/system_ext3_$(1).img:m:md5
PUBLISHING_FILES_$(2)+=$(2)/userdata_ext3_$(1).img:m:md5
endef

#$1:internal or external
#$2:build variant
define package-droid-mmc-config
.PHONY: package_droid_mmc_$(1)_$(2)
package_droid_mmc_$(1)_$(2):
	$$(log) "[$(2)]package root file system for booting android from SD card or NFS for $(1)."
	$$(hide)if [ -d $$(OUTPUT_DIR)/$(2)/root_nfs ]; then rm -fr $$(OUTPUT_DIR)/$(2)/root_nfs; fi
	$$(hide)cp -r -p $$(SRC_DIR)/out/target/product/$$(DROID_PRODUCT)/root $$(OUTPUT_DIR)/$(2)/root_nfs && \
	cp -p -r $$(SRC_DIR)/out/target/product/$$(DROID_PRODUCT)/system $$(OUTPUT_DIR)/$(2)/root_nfs
	$$(log) "  updating the modules..."
	$$(hide)if [ -d $$(OUTPUT_DIR)/$(2)/modules ]; then rm -fr $$(OUTPUT_DIR)/$(2)/modules; fi
	$$(hide)cd $$(OUTPUT_DIR)/$(2) && tar xzf modules_android_mmc.tgz && cp -r modules $$(OUTPUT_DIR)/$(2)/root_nfs/system/lib/
	$$(log) "  modifying root nfs folder..."
	$$(hide)cd $$(OUTPUT_DIR)/$(2)/root_nfs && $$(MY_SCRIPT_DIR)/twist_root_nfs.sh 
	$$(log) "copy demo media files to /sdcard if there are demo media files..."
	$$(hide)if [ -d "$$(DEMO_MEDIA_DIR)" ]; then \
			mkdir -p $$(OUTPUT_DIR)/$(2)/root_nfs/sdcard && \
			cp -r $$(DEMO_MEDIA_DIR)/* $$(OUTPUT_DIR)/$(2)/root_nfs/sdcard/ && \
			echo "  done."; \
		   else \
			echo "    !!!demo media is not found."; \
		   fi
	$$(log) "  packaging the root_nfs.tgz..."
	$$(hide)cd $$(OUTPUT_DIR)/$(2) && tar czf root_nfs_$(1).tgz root_nfs/
	$$(log) "  done for package_droid_mmc_$(1)_$(2)."

PUBLISHING_FILES_$(2)+=$(2)/root_nfs_$(1).tgz:m:md5 
endef

#<os>:<storage>:<kernel_cfg>:<root>
# os: the operating system
# storage: the OS will startup from which storage
# kernel_cfg:kernel config file used to build the kernel
# root: optional. If specified, indicating that the kernel Image has a root RAM file system.
#example: android:mlc:pxa168_android_mlc_defconfig:root
# kernel_configs:=
#
kernel_configs:=android:mmc:mmp2_android_1gddr_defconfig 

export KERNEL_TOOLCHAIN_PREFIX
export MAKE_JOBS

#$1:kernel_config
#$2:build variant
define define-kernel-target
tw:=$$(subst :,  , $(1) )
os:=$$(word 1, $$(tw) )
storage:=$$(word 2, $$(tw) )
kernel_cfg:=$$(word 3, $$(tw) )
root:=$$(word 4, $$(tw) )

#make sure that PUBLISHING_FILES_XXX is a simply expanded variable
#PUBLISHING_FILES_$(2):=$(PUBLISHING_FILES_$(2)) $(2)/uImage.$$(os):m:md5
PUBLISHING_FILES_$(2)+=$(2)/uImage.$$(os):m:md5
PUBLISHING_FILES_$(2)+=$(2)/uImage.up.$$(os):m:md5
PUBLISHING_FILES_$(2)+=$(2)/rdinit:m:md5
PUBLISHING_FILES_$(2)+=$(2)/vmlinux:o:md5
PUBLISHING_FILES_$(2)+=$(2)/System.map:o:md5
PUBLISHING_FILES_$(2)+=$(2)/modules_$$(os)_$$(storage).tgz:m:md5
PUBLISHING_FILES_$(2)+=$(2)/symbols_lib.tgz:o:md5

build_kernel_$$(os)_$$(storage)_$(2): private_os:=$$(os)
build_kernel_$$(os)_$$(storage)_$(2): private_storage:=$$(storage)
build_kernel_$$(os)_$$(storage)_$(2): private_root:=$$(root)
build_kernel_$$(os)_$$(storage)_$(2): private_kernel_cfg:=$$(kernel_cfg)
build_kernel_$$(os)_$$(storage)_$(2): private_root:=$$(root)
build_kernel_$$(os)_$$(storage)_$(2): output_dir $$(if $$(findstring root,$$(root)), cp_$$(os)_root_dir_$$(storage)_$(2) ) 
	$$(log) "[$(2)]starting to build kernel for booting $$(private_os) from $$(private_storage) ..."
	$$(log) "    kernel_config: $$(private_kernel_cfg): ..."
	$$(hide)cd $$(SRC_DIR)/$$(KERNELSRC_TOPDIR) && \
	KERNEL_CONFIG=$$(private_kernel_cfg) make clean all 
	$$(hide)mkdir -p $$(OUTPUT_DIR)/$(2)
	$$(log) "    copy kernel and module files ..."
	$$(hide)cp $$(SRC_DIR)/$$(KERNELSRC_TOPDIR)/out/uImage $$(OUTPUT_DIR)/$(2)/uImage.$$(private_os)
	$$(hide)cp $$(SRC_DIR)/$$(KERNELSRC_TOPDIR)/out/uImage.up $$(OUTPUT_DIR)/$(2)/uImage.up.$$(private_os)
	$$(hide)cp $$(SRC_DIR)/$$(KERNELSRC_TOPDIR)/out/rdinit $$(OUTPUT_DIR)/$(2)
	$$(hide)cp $$(SRC_DIR)/$$(KERNELSRC_TOPDIR)/kernel/vmlinux $$(OUTPUT_DIR)/$(2)
	$$(hide)cp $$(SRC_DIR)/$$(KERNELSRC_TOPDIR)/kernel/System.map $$(OUTPUT_DIR)/$(2)
	$$(hide)if [ -d $$(OUTPUT_DIR)/$(2)/modules ]; then rm -fr $$(OUTPUT_DIR)/$(2)/modules; fi &&\
	mkdir -p $$(OUTPUT_DIR)/$(2)/modules
	$$(hide)cp $$(SRC_DIR)/$$(KERNELSRC_TOPDIR)/out/modules/* $$(OUTPUT_DIR)/$(2)/modules
	$$(hide)cd $$(OUTPUT_DIR)/$(2) && tar czf modules_$$(private_os)_$$(private_storage).tgz modules/ 
	$$(hide)cp -a $$(SRC_DIR)/out/target/product/$$(DROID_PRODUCT)/symbols/system/lib $$(OUTPUT_DIR)/$(2)/
	$$(hide)cd $$(OUTPUT_DIR)/$(2) && tar czf symbols_lib.tgz lib && rm lib -rf
	$(log) "  done."

.PHONY: build_kernel_$$(os)_$$(storage)_$(2)
build_kernel_$(2): build_kernel_$$(os)_$$(storage)_$(2)
endef

$(foreach bv,$(BUILD_VARIANTS), $(eval $(call define-build-droid-kernel,$(bv)) ) \
								$(eval $(call define-build-droid-root,$(bv)) ) \
								$(eval $(call define-build-droid-pkgs,$(bv)) ) \
								$(eval $(call define-build-droid-config,$(bv),internal) ) \
								$(eval $(call define-build-droid-config,$(bv),external) ) \
								$(eval $(call rebuild-droid-config,internal,$(bv)) )\
								$(eval $(call rebuild-droid-config,external,$(bv)) )\
								$(eval $(call package-droid-mlc-config,internal,$(bv)) )\
								$(eval $(call package-droid-mlc-config,external,$(bv)) )\
								$(eval $(call package-droid-mmc-config,internal,$(bv)) )\
								$(eval $(call package-droid-mmc-config,external,$(bv)) ) \
								$(foreach kc, $(kernel_configs),$(eval $(call define-kernel-target,$(kc),$(bv)) ) )\
)

