#check if the required variables have been set.
#$(call check-variables,BUILD_VARIANTS)

#
# Include goal for build UBoot and obm
#
include $(ABS_SOC)/build-uboot-obm.mk

# Include goal for build software downloader
include $(ABS_SOC)/build-swd.mk

DROID_TYPE:=release
KERNELSRC_TOPDIR:=kernel

define define-clean-droid-kernel
tw:=$$(subst :,  , $(1))
product:=$$(word 1, $$(tw))
device:=$$(word 2, $$(tw))

.PHONY:clean_droid_kernel_$$(product)
clean_droid_kernel_$$(product): private_product:=$$(product)
clean_droid_kernel_$$(product): private_device:=$$(device)
clean_droid_kernel_$$(product):
	$(log) "clean android ..."
	$(hide)cd $$(SRC_DIR) && \
	rm -rf out/target/product/$$(private_device)
	$(log) "    done"
endef

#$1:build device
define define-build-droid-kernel
tw:=$$(subst :,  , $(1))
product:=$$(word 1, $$(tw))
device:=$$(word 2, $$(tw))

build_droid_kernel_$$(product): build_kernel_$$(product)
build_droid_kernel_$$(product): build_droid_root_$$(product)
build_droid_kernel_$$(product): build_uboot_$$(product)
build_droid_kernel_$$(product): build_droid_pkgs_$$(product)
build_droid_kernel_$$(product): build_obm_$$(product)
build_droid_kernel_$$(product): build_swd_$$(product)
endef

#$1:build device
define define-build-droid-root
tw:=$$(subst :,  , $(1))
product:=$$(word 1, $$(tw))
device:=$$(word 2, $$(tw))

PUBLISHING_FILES+=$$(product)/boot.img:o:md5
PUBLISHING_FILES+=$$(product)/system.img:m:md5
PUBLISHING_FILES+=$$(product)/userdata.img:o:md5
PUBLISHING_FILES+=$$(product)/ramdisk.img:o:md5
PUBLISHING_FILES+=$$(product)/ramdisk-recovery.img:o:md5
PUBLISHING_FILES+=$$(product)/cache.img:o:md5

PUBLISHING_FILES+=$$(product)/primary_gpt:o:md5
PUBLISHING_FILES+=$$(product)/secondary_gpt:o:md5

.PHONY: build_droid_root_$$(product)
build_droid_root_$$(product): private_product:=$$(product)
build_droid_root_$$(product): private_device:=$$(device)
build_droid_root_$$(product): build_kernel_$$(product)
build_droid_root_$$(product): output_dir
	$$(log) "[$$(private_product)]building android source code ..."
	$$(hide)cd $$(SRC_DIR) && \
	. build/envsetup.sh && \
	lunch $$(private_product)-$$(DROID_VARIANT) && \
	make -j$$(MAKE_JOBS)
	$$(hide)if [ -f $$(SRC_DIR)/out/target/product/$$(private_device)/boot.img ]; then cp $$(SRC_DIR)/out/target/product/$$(private_device)/boot.img $$(OUTPUT_DIR)/$$(private_product)/; fi
	$$(hide)if [ -f $$(SRC_DIR)/out/target/product/$$(private_device)/system.img ]; then cp $$(SRC_DIR)/out/target/product/$$(private_device)/system.img $$(OUTPUT_DIR)/$$(private_product)/; fi
	$$(hide)if [ -f $$(SRC_DIR)/out/target/product/$$(private_device)/userdata.img ]; then cp $$(SRC_DIR)/out/target/product/$$(private_device)/userdata.img $$(OUTPUT_DIR)/$$(private_product)/; fi
	$$(hide)if [ -f $$(SRC_DIR)/out/target/product/$$(private_device)/ramdisk-recovery.img ]; then cp $$(SRC_DIR)/out/target/product/$$(private_device)/ramdisk-recovery.img $$(OUTPUT_DIR)/$$(private_product)/; fi
	$$(hide)if [ -f $$(SRC_DIR)/out/target/product/$$(private_device)/ramdisk.img ]; then cp $$(SRC_DIR)/out/target/product/$$(private_device)/ramdisk.img $$(OUTPUT_DIR)/$$(private_product)/; fi
	$$(hide)if [ -f $$(SRC_DIR)/out/target/product/$$(private_device)/cache.img ]; then cp $$(SRC_DIR)/out/target/product/$$(private_device)/cache.img $$(OUTPUT_DIR)/$$(private_product)/; fi
	$$(hide)if [ -f $$(SRC_DIR)/out/target/product/$$(private_device)/primary_gpt ]; then cp $$(SRC_DIR)/out/target/product/$$(private_device)/primary_gpt $$(OUTPUT_DIR)/$$(private_product)/; fi
	$$(hide)if [ -f $$(SRC_DIR)/out/target/product/$$(private_device)/secondary_gpt ]; then cp $$(SRC_DIR)/out/target/product/$$(private_device)/secondary_gpt $$(OUTPUT_DIR)/$$(private_product)/; fi
	echo "    generating symbols_lib.tgz..." && \
		cp -a $$(SRC_DIR)/out/target/product/$$(private_device)/symbols/system/lib $$(OUTPUT_DIR)/$$(private_product) && \
		cd $$(OUTPUT_DIR)/$$(private_product) && tar czf symbols_lib.tgz lib && rm lib -rf
	$(log) "  done"

PUBLISHING_FILES+=$$(product)/symbols_lib.tgz:o:md5
endef

#$1: build device
#$2: internal or external
define define-build-droid-config

tw:=$$(subst :,  , $(1))
product:=$$(word 1, $$(tw))
device:=$$(word 2, $$(tw))

build_droid_pkgs_$$(product): build_droid_$$(product)_$(2)

.PHONY: build_droid_$$(product)_$(2)
build_droid_$$(product)_$(2): private_product:=$$(product)
build_droid_$$(product)_$(2): private_device:=$$(device)
build_droid_$$(product)_$(2): package_droid_nfs_$$(product)_$(2)
	$$(log) "build_droid_$$(private_product)_$(2) is done, reseting the source code."
	$$(hide)cd $$(SRC_DIR)/device/marvell/$$(private_device)/ &&\
		git reset --hard
	$$(log) "  done"
endef

#$1:build device
#$2:internal or external
define package-droid-nfs-config
tw:=$$(subst :,  , $(1))
product:=$$(word 1, $$(tw))
device:=$$(word 2, $$(tw))

PUBLISHING_FILES+=$$(product)/root_nfs_$(2).tgz:m:md5

.PHONY: package_droid_nfs_$$(product)_$(2)
package_droid_nfs_$$(product)_$(2): private_product:=$$(product)
package_droid_nfs_$$(product)_$(2): private_device:=$$(device)
package_droid_nfs_$$(product)_$(2):
	$$(log) "[$$(private_product)]package root file system for booting android from SD card or NFS for $(2)."
	$$(hide)if [ -d $$(OUTPUT_DIR)/$$(private_product)/root_nfs ]; then rm -fr $$(OUTPUT_DIR)/$$(private_product)/root_nfs; fi
	$$(hide)cp -r -p $$(SRC_DIR)/out/target/product/$$(private_device)/root $$(OUTPUT_DIR)/$$(private_product)/root_nfs && \
	cp -p -r $$(SRC_DIR)/out/target/product/$$(private_device)/system $$(OUTPUT_DIR)/$$(private_product)/root_nfs
	$$(log) "  modifying root nfs folder..."
	$$(hide)cd $$(OUTPUT_DIR)/$$(private_product)/root_nfs && $$(ABS_TOP_DIR)/$$(ABS_SOC)/twist_root_nfs.sh
	$$(log) "  packaging the root_nfs.tgz..."
	$$(hide)cd $$(OUTPUT_DIR)/$$(private_product) && tar czf root_nfs_$(2).tgz root_nfs/
	$$(log) "  done for package_droid_nfs_$$(private_product)_$(2)."
endef

export MAKE_JOBS

#$1:build device
#$2:kernel_config
define define-kernel-target
tw:=$$(subst :,  , $(1))
product:=$$(word 1, $$(tw))
device:=$$(word 2, $$(tw))

tw:=$$(subst :,  , $(2))
os:=$$(word 1, $$(tw))
kernel_cfg:=$$(word 2, $$(tw))

#make sure that PUBLISHING_FILES_XXX is a simply expanded variable
PUBLISHING_FILES+=$$(product)/zImage.$$(os):o:md5
PUBLISHING_FILES+=$$(product)/zImage_recovery.$$(os):o:md5
PUBLISHING_FILES+=$$(product)/uImage.$$(os):o:md5
PUBLISHING_FILES+=$$(product)/uImage_recovery.$$(os):o:md5
PUBLISHING_FILES+=$$(product)/vmlinux.$$(os):o:md5
PUBLISHING_FILES+=$$(product)/System.map.$$(os):o:md5

build_kernel_$$(product): build_kernel_$$(os)_$$(kernel_cfg)

.PHONY: build_kernel_$$(os)_$$(kernel_cfg)
build_kernel_$$(os)_$$(kernel_cfg): private_os:=$$(os)
build_kernel_$$(os)_$$(kernel_cfg): private_product:=$$(product)
build_kernel_$$(os)_$$(kernel_cfg): private_cfg:=$$(kernel_cfg)
build_kernel_$$(os)_$$(kernel_cfg): koutput:=$$(SRC_DIR)/out/target/product/$$(device)/kbuild-$$(kernel_cfg)
build_kernel_$$(os)_$$(kernel_cfg): output_dir
	$$(log) "build kernel for booting $$(private_os) on $$(private_product)..."
	$$(log) "    kernel_config: $$(private_cfg): ..."
	$$(hide)cd $$(SRC_DIR)/ && \
	. build/envsetup.sh && \
	lunch $$(private_product)-$$(DROID_VARIANT) && \
	cd $$(KERNELSRC_TOPDIR) && \
	KERNEL_CONFIG=$$(private_cfg) make clean all
	$$(hide)mkdir -p $$(OUTPUT_DIR)/$$(private_product)
	$$(log) "    copy kernel files ..."
	$$(hide)if [ -f $$(koutput)/arch/arm/boot/zImage ]; then cp $$(koutput)/arch/arm/boot/zImage $$(OUTPUT_DIR)/$$(private_product)/zImage.$$(private_os); fi
	$$(hide)if [ -f $$(koutput)/arch/arm/boot/uImage ]; then cp $$(koutput)/arch/arm/boot/uImage $$(OUTPUT_DIR)/$$(private_product)/uImage.$$(private_os); fi
	$$(hide)cp $$(koutput)/vmlinux $$(OUTPUT_DIR)/$$(private_product)/vmlinux.$$(private_os)
	$$(hide)cp $$(koutput)/System.map $$(OUTPUT_DIR)/$$(private_product)/System.map.$$(private_os)
	$$(log) "  done."
endef

# <os>:<kernel_cfg>:
# os: the operating system
# kernel_cfg:kernel config file used to build the kernel
# example: android:pxa610_android_defconfig:
#
kernel_configs:=android:eden_and_defconfig:
boot_configs:=eden_concord_sharp_1080p eden_concord_otm_720p eden_concord_lg_720p

$(foreach bd,$(ABS_BUILD_DEVICES),\
	$(eval $(call define-clean-droid-kernel,$(bd))) \
	$(eval $(call define-build-droid-kernel,$(bd))) \
	$(foreach kc,$(kernel_configs), \
		$(eval $(call define-kernel-target,$(bd),$(kc)))) \
	$(eval $(call define-build-droid-root,$(bd))) \
	$(foreach bc,$(boot_configs), \
		$(eval $(call define-uboot-target,$(bd),$(bc)))) \
	$(foreach kc,$(kernel_configs), \
		$(foreach bc,$(boot_configs), \
			$(eval $(call define-build-obm,$(bd),$(kc),$(bc))))) \
	$(eval $(call define-build-swd,$(bd))) \
	$(eval $(call define-build-droid-config,$(bd),internal)) \
	$(eval $(call package-droid-nfs-config,$(bd),internal)) \
)
