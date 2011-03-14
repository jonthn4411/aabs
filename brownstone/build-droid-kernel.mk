#check if the required variables have been set.
#$(call check-variables,BUILD_VARIANTS)

#
# Include goal for build UBoot and obm
#
include $(BOARD)/build-uboot-obm.mk

DEMO_MEDIA_DIR:=/autobuild/demomedia
MY_SCRIPT_DIR:=$(TOP_DIR)/brownstone

DROID_PRODUCT:=brownstone
DROID_TYPE:=release
DROID_VARIANT:=user

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

#$1:build variant
define define-build-droid-kernel
.PHONY:build_droid_kernel_$(1)
build_droid_kernel_$(1): build_uboot_obm_$(1) build_kernel_$(1) build_droid_root_$(1) build_droid_pkgs_$(1)
endef

#$1:build variant
define define-build-droid-root
.PHONY: build_droid_root_$(1) 
build_droid_root_$(1): output_dir
	$$(log) "[$(1)]updating the modules..."
	$$(hide)rm -fr $$(OUTPUT_DIR)/$(1)/modules
	$$(hide)mkdir -p $$(OUTPUT_DIR)/$(1)
	$$(hide)cd $$(OUTPUT_DIR)/$(1) && tar xzf modules_android_mmc.tgz
	$$(log) "[$(1)]building android source code ..."
	$$(hide)export ANDROID_PREBUILT_MODULES=$$(OUTPUT_DIR)/$(1)/modules && \
	cd $$(SRC_DIR) && \
	source ./build/envsetup.sh && \
	chooseproduct $$(DROID_PRODUCT) && choosetype $$(DROID_TYPE) && choosevariant $$(DROID_VARIANT) && \
	make -j$$(MAKE_JOBS)
	echo "    copy GPT files..." && \
		cp -p $(SRC_DIR)/out/target/product/$$(DROID_PRODUCT)/primary_gpt_8g $$(OUTPUT_DIR)/$(1)/ && \
		cp -p $(SRC_DIR)/out/target/product/$$(DROID_PRODUCT)/secondary_gpt_8g $$(OUTPUT_DIR)/$(1)/
	echo "    copy ramfs files..." && \
		cp -p $(SRC_DIR)/out/target/product/$$(DROID_PRODUCT)/ramdisk.img $$(OUTPUT_DIR)/$(1)/ && \
		cp -p $(SRC_DIR)/out/target/product/$$(DROID_PRODUCT)/ramdisk_recovery.img $$(OUTPUT_DIR)/$(1)/
	echo "    copy filesystem files..." && \
		cp -p $(SRC_DIR)/out/target/product/$$(DROID_PRODUCT)/system.img $$(OUTPUT_DIR)/$(1)/
	echo "    copy update packages..." && \
		cp -p $(SRC_DIR)/out/target/product/$$(DROID_PRODUCT)/update_droid.zip $$(OUTPUT_DIR)/$(1)/ && \
	echo "    generating symbols_lib.tgz..." && \
		cp -a $$(SRC_DIR)/out/target/product/$$(DROID_PRODUCT)/symbols/system/lib $$(OUTPUT_DIR)/$(1)/ && \
		cd $$(OUTPUT_DIR)/$(1) && tar czf symbols_lib.tgz lib && rm lib -rf
	$(log) "  done"

PUBLISHING_FILES_$(1)+=$(1)/primary_gpt_8g:m:md5
PUBLISHING_FILES_$(1)+=$(1)/secondary_gpt_8g:m:md5
PUBLISHING_FILES_$(1)+=$(1)/ramdisk.img:m:md5
PUBLISHING_FILES_$(1)+=$(1)/ramdisk_recovery.img:m:md5
PUBLISHING_FILES_$(1)+=$(1)/system.img:m:md5
PUBLISHING_FILES_$(1)+=$(1)/update_droid.zip:m:md5
PUBLISHING_FILES_$(1)+=$(1)/symbols_lib.tgz:o:md5
endef

#$1:build variant
define define-build-droid-pkgs
.PHONY:build_droid_pkgs_$(1)
build_droid_pkgs_$(1): 
endef

#$1: build variant
#$2: internal or external
define define-build-droid-config
.PHONY: build_droid_$(1)_$(2)
build_droid_$(1)_$(2): package_droid_nfs_$(1)_$(2)
	$$(log) "build_droid_$(1)_$(2) is done, reseting the source code."
	$$(hide)cd $$(SRC_DIR)/vendor/marvell/$$(DROID_PRODUCT)/ &&\
		git reset --hard
	$$(log) "  done"

build_droid_pkgs_$(1): build_droid_$(1)_$(2)
endef

#$1:internal or external
#$2:build variant
define package-droid-nfs-config
.PHONY: package_droid_nfs_$(1)_$(2)
package_droid_nfs_$(1)_$(2):
	$$(log) "[$(1)]package root file system for booting android from SD card or NFS for $(2)."
	$$(hide)if [ -d $$(OUTPUT_DIR)/$(1)/root_nfs ]; then rm -fr $$(OUTPUT_DIR)/$(1)/root_nfs; fi
	$$(hide)cp -r -p $$(SRC_DIR)/out/target/product/$$(DROID_PRODUCT)/root $$(OUTPUT_DIR)/$(1)/root_nfs && \
	cp -p -r $$(SRC_DIR)/out/target/product/$$(DROID_PRODUCT)/system $$(OUTPUT_DIR)/$(1)/root_nfs
	$$(log) "  updating the modules..."
	$$(hide)if [ -d $$(OUTPUT_DIR)/$(1)/modules ]; then rm -fr $$(OUTPUT_DIR)/$(1)/modules; fi
	$$(hide)cd $$(OUTPUT_DIR)/$(1) && tar xzf modules_android_mmc.tgz && cp -r modules $$(OUTPUT_DIR)/$(1)/root_nfs/system/lib/
	$$(log) "  modifying root nfs folder..."
	$$(hide)cd $$(OUTPUT_DIR)/$(1)/root_nfs && $$(MY_SCRIPT_DIR)/twist_root_nfs.sh
	$$(log) "copy demo media files to /sdcard if there are demo media files..."
	$$(hide)if [ -d "$$(DEMO_MEDIA_DIR)" ]; then \
			mkdir -p $$(OUTPUT_DIR)/$(1)/root_nfs/sdcard && \
			cp -r $$(DEMO_MEDIA_DIR)/* $$(OUTPUT_DIR)/$(1)/root_nfs/sdcard/ && \
			echo "  done."; \
		   else \
			echo "    !!!demo media is not found."; \
		   fi
	$$(log) "  packaging the root_nfs.tgz..."
	$$(hide)cd $$(OUTPUT_DIR)/$(1) && tar czf root_nfs_$(2).tgz root_nfs/
	$$(log) "  done for package_droid_nfs_$(1)_$(2)."

PUBLISHING_FILES_$(1)+=$(1)/root_nfs_$(2).tgz:m:md5
endef

#<os>:<storage>:<kernel_cfg>:<root>
# os: the operating system
# storage: the OS will startup from which storage
# kernel_cfg:kernel config file used to build the kernel
# root: optional. If specified, indicating that the kernel zImage has a root RAM file system.
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
PUBLISHING_FILES_$(2)+=$(2)/zImage.$$(os):m:md5
PUBLISHING_FILES_$(2)+=$(2)/zImage_recovery.$$(os):m:md5
PUBLISHING_FILES_$(2)+=$(2)/vmlinux:o:md5
PUBLISHING_FILES_$(2)+=$(2)/System.map:o:md5
PUBLISHING_FILES_$(2)+=$(2)/modules_$$(os)_$$(storage).tgz:m:md5

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
	$$(hide)cp $$(SRC_DIR)/$$(KERNELSRC_TOPDIR)/out/zImage $$(OUTPUT_DIR)/$(2)/zImage.$$(private_os)
	$$(hide)cp $$(SRC_DIR)/$$(KERNELSRC_TOPDIR)/out/zImage_recovery $$(OUTPUT_DIR)/$(2)/zImage_recovery.$$(private_os)
	$$(hide)cp $$(SRC_DIR)/$$(KERNELSRC_TOPDIR)/kernel/vmlinux $$(OUTPUT_DIR)/$(2)
	$$(hide)cp $$(SRC_DIR)/$$(KERNELSRC_TOPDIR)/kernel/System.map $$(OUTPUT_DIR)/$(2)
	$$(hide)if [ -d $$(OUTPUT_DIR)/$(2)/modules ]; then rm -fr $$(OUTPUT_DIR)/$(2)/modules; fi &&\
	mkdir -p $$(OUTPUT_DIR)/$(2)/modules
	$$(hide)cp $$(SRC_DIR)/$$(KERNELSRC_TOPDIR)/out/modules/* $$(OUTPUT_DIR)/$(2)/modules
	$$(hide)cd $$(OUTPUT_DIR)/$(2) && tar czf modules_$$(private_os)_$$(private_storage).tgz modules/ 
	$(log) "  done."

.PHONY: build_kernel_$$(os)_$$(storage)_$(2)
build_kernel_$(2): build_kernel_$$(os)_$$(storage)_$(2)
endef

$(foreach bv,$(BUILD_VARIANTS), \
	$(eval $(call define-build-uboot-obm,$(bv)) ) \
	$(eval $(call define-build-droid-kernel,$(bv)) ) \
	$(foreach kc, $(kernel_configs), \
		$(eval $(call define-kernel-target,$(kc),$(bv)) ) ) \
	$(eval $(call define-build-droid-root,$(bv)) ) \
	$(eval $(call define-build-droid-pkgs,$(bv)) ) \
	$(eval $(call define-build-droid-config,$(bv),internal) ) \
	$(eval $(call package-droid-nfs-config,$(bv),internal) ) \
)
