#check if the required variables have been set.
#$(call check-variables,BUILD_VARIANTS)

#
# Include goal for build UBoot and obm
#
include $(BOARD)/build-uboot-obm.mk

MY_SCRIPT_DIR:=$(TOP_DIR)/yellowstone

DROID_PRODUCT:=yellowstone
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

#$1:build variant
define define-build-droid-kernel
.PHONY:build_droid_kernel_$(1)
build_droid_kernel_$(1): build_kernel_$(1)
build_droid_kernel_$(1): build_droid_root_$(1)
build_droid_kernel_$(1): build_uboot_obm_$(1)
build_droid_kernel_$(1): build_droid_pkgs_$(1)
endef

#$1:build variant
define define-build-droid-root
.PHONY: build_droid_root_$(1) 
build_droid_root_$(1): output_dir
	$$(log) "[$(1)]building android source code ..."
	$$(hide)cd $$(SRC_DIR) && \
	source ./build/envsetup.sh && \
	chooseproduct $$(DROID_PRODUCT) && choosetype $$(DROID_TYPE) && choosevariant $$(DROID_VARIANT) && \
	ANDROID_PREBUILT_MODULES=kernel/out/modules make -j$$(MAKE_JOBS)
	echo "    copy GPT files..." && \
		cp -p $(SRC_DIR)/out/target/product/$$(DROID_PRODUCT)/primary_gpt_8g $$(OUTPUT_DIR)/$(1)/ && \
		cp -p $(SRC_DIR)/out/target/product/$$(DROID_PRODUCT)/secondary_gpt_8g $$(OUTPUT_DIR)/$(1)/
	echo "    copy ramfs files..." && \
		cp -p $(SRC_DIR)/out/target/product/$$(DROID_PRODUCT)/ramdisk.img $$(OUTPUT_DIR)/$(1)/
	echo "    copy system.img ..." && \
		cp -p $(SRC_DIR)/out/target/product/$$(DROID_PRODUCT)/system.img $$(OUTPUT_DIR)/$(1)/
	$$(hide)if [ -f $(SRC_DIR)/out/target/product/$$(DROID_PRODUCT)/userdata.img ]; then \
		echo "    copy userdata.img ..." && \
		cp -p $(SRC_DIR)/out/target/product/$$(DROID_PRODUCT)/userdata.img $$(OUTPUT_DIR)/$(1)/; \
	fi
	echo "    generating symbols_lib.tgz..." && \
		cp -a $$(SRC_DIR)/out/target/product/$$(DROID_PRODUCT)/symbols/system/lib $$(OUTPUT_DIR)/$(1)/ && \
		cd $$(OUTPUT_DIR)/$(1) && tar czf symbols_lib.tgz lib && rm lib -rf
	$(log) "  done"

PUBLISHING_FILES_$(1)+=$(1)/primary_gpt_8g:m:md5
PUBLISHING_FILES_$(1)+=$(1)/secondary_gpt_8g:m:md5
PUBLISHING_FILES_$(1)+=$(1)/ramdisk.img:m:md5
PUBLISHING_FILES_$(1)+=$(1)/system.img:m:md5
PUBLISHING_FILES_$(1)+=$(1)/userdata.img:o:md5
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

#$1:build variant
#$2:internal or external
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
	$$(log) "  packaging the root_nfs.tgz..."
	$$(hide)cd $$(OUTPUT_DIR)/$(1) && tar czf root_nfs_$(2).tgz root_nfs/
	$$(log) "  done for package_droid_nfs_$(1)_$(2)."

PUBLISHING_FILES_$(1)+=$(1)/root_nfs_$(2).tgz:m:md5
endef

#<os>:<storage>:<kernel_cfg>:<root>
# os: the operating system
# storage: the OS will startup from which storage
# kernel_cfg:kernel config file used to build the kernel
# root: optional. If specified, indicating that the kernel Image has a root RAM file system.
#example: android:mlc:pxa168_android_mlc_defconfig:root
# kernel_configs:=
#
kernel_configs:=android:mmc:bad_config

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
PUBLISHING_FILES_$(2)+=$(2)/uImage.smp.$$(os):m:md5
PUBLISHING_FILES_$(2)+=$(2)/uImage.up.$$(os):m:md5
PUBLISHING_FILES_$(2)+=$(2)/uImage.cm.$$(os):m:md5
PUBLISHING_FILES_$(2)+=$(2)/rdinit:m:md5
PUBLISHING_FILES_$(2)+=$(2)/rdroot.tgz:m:md5
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
	$$(hide)cp $$(SRC_DIR)/$$(KERNELSRC_TOPDIR)/out/uImage.smp          $$(OUTPUT_DIR)/$(2)/uImage.smp.$$(private_os)
	$$(hide)cp $$(SRC_DIR)/$$(KERNELSRC_TOPDIR)/out/uImage.up           $$(OUTPUT_DIR)/$(2)/uImage.up.$$(private_os)
	$$(hide)cp $$(SRC_DIR)/$$(KERNELSRC_TOPDIR)/out/uImage.cm           $$(OUTPUT_DIR)/$(2)/uImage.cm.$$(private_os)
	$$(hide)cp $$(SRC_DIR)/$$(KERNELSRC_TOPDIR)/out/rdinit        $$(OUTPUT_DIR)/$(2)
	$$(hide)cp $$(SRC_DIR)/$$(KERNELSRC_TOPDIR)/rdroot/rdroot.tgz $$(OUTPUT_DIR)/$(2)
	$$(hide)cp $$(SRC_DIR)/$$(KERNELSRC_TOPDIR)/kernel/vmlinux    $$(OUTPUT_DIR)/$(2)
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
	$(eval $(call define-build-droid-kernel,$(bv)) ) \
	$(foreach kc, $(kernel_configs), \
		$(eval $(call define-kernel-target,$(kc),$(bv)) ) ) \
	$(eval $(call define-build-droid-root,$(bv)) ) \
	$(eval $(call define-build-droid-pkgs,$(bv)) ) \
	$(eval $(call define-build-droid-config,$(bv),internal) ) \
	$(eval $(call package-droid-nfs-config,$(bv),internal) ) \
)
