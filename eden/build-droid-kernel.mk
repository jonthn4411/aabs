#check if the required variables have been set.
#$(call check-variables,BUILD_VARIANTS)

#
# Include goal for build UBoot and obm
#
#include $(ABS_SOC)/build-uboot-obm.mk

# Include goal for build software downloader
#include $(ABS_SOC)/build-swd.mk

DROID_TYPE:=release
KERNELSRC_TOPDIR:=kernel

define define-clean-droid-kernel
tw:=$$(subst :,  , $(1))
product:=$$(word 1, $$(tw))
device:=$$(word 2, $$(tw))
#$$(warning define-clean-droid-kernel arg1=$(1) tw=$$(tw) product=$$(product) device=$$(device))
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
#$$(warning define-build-droid-kernel arg1=$(1) tw=$$(tw) product=$$(product) device=$$(device))
build_droid_kernel_$$(product): build_droid_root_$$(product)
build_droid_kernel_$$(product): build_droid_pkgs_$$(product)
build_droid_kernel_$$(product): build_droid_otapackage_$$(product)
endef

#$1:build device
define define-build-droid-root
tw:=$$(subst :,  , $(1))
product:=$$(word 1, $$(tw))
device:=$$(word 2, $$(tw))
#$$(warning define-build-droid-root arg1=$(1) tw=$$(tw) product=$$(product) device=$$(device))
PUBLISHING_FILES+=$$(product)/boot.img:o:md5
PUBLISHING_FILES+=$$(product)/system.img:m:md5
PUBLISHING_FILES+=$$(product)/userdata.img:o:md5
PUBLISHING_FILES+=$$(product)/ramdisk.img:o:md5
PUBLISHING_FILES+=$$(product)/ramdisk-recovery.img:o:md5
PUBLISHING_FILES+=$$(product)/cache.img:o:md5
PUBLISHING_FILES+=$$(product)/primary_gpt:o:md5
PUBLISHING_FILES+=$$(product)/secondary_gpt:o:md5
PUBLISHING_FILES+=$$(product)/System.map:o:md5
PUBLISHING_FILES+=$$(product)/uImage.android:o:md5
PUBLISHING_FILES+=$$(product)/zImage:o:md5
PUBLISHING_FILES+=$$(product)/vmlinux:o:md5

##!!## blf files
PUBLISHING_FILES+=$$(product)/blf:o:md5
PUBLISHING_FILES2+=Software_Downloader.zip:./:m:md5
ifeq ($(product),concord_tz)
PUBLISHING_FILES+=$$(product)/teesst.img:o:md5
PUBLISHING_FILES+=$$(product)/tee_tw.bin:o:md5
PUBLISHING_FILES+=$$(product)/wtm_rel_eden_RealOTP.bin:o:md5
PUBLISHING_FILES+=$$(product)/wtm_rel_eden_VirtualOTP.bin:o:md5
endif

.PHONY: build_droid_root_$$(product)
build_droid_root_$$(product): private_product:=$$(product)
build_droid_root_$$(product): private_device:=$$(device)
build_droid_root_$$(product): output_dir
	$$(log) "[$$(private_product)]building android source code ..."
	$$(hide)mkdir -p $$(OUTPUT_DIR)/$$(private_product)
	$$(hide)cd $$(SRC_DIR) && \
	. build/envsetup.sh && \
	lunch $$(private_product)-$$(DROID_VARIANT) && \
	make -j$$(MAKE_JOBS)
	$$(hide)if [ -f $$(SRC_DIR)/out/target/product/$$(private_device)/security/teesst.img ]; then cp $$(SRC_DIR)/out/target/product/$$(private_device)/security/teesst.img $$(OUTPUT_DIR)/$$(private_product)/; fi
	$$(hide)if [ -f $$(SRC_DIR)/out/target/product/$$(private_device)/security/tee_tw.bin ]; then cp $$(SRC_DIR)/out/target/product/$$(private_device)/security/tee_tw.bin $$(OUTPUT_DIR)/$$(private_product)/; fi
	$$(hide)if [ -f $$(SRC_DIR)/out/target/product/$$(private_device)/security/wtm_rel_eden_RealOTP.bin ]; then cp $$(SRC_DIR)/out/target/product/$$(private_device)/security/wtm_rel_eden_RealOTP.bin $$(OUTPUT_DIR)/$$(private_product)/; fi
	$$(hide)if [ -f $$(SRC_DIR)/out/target/product/$$(private_device)/security/wtm_rel_eden_VirtualOTP.bin ]; then cp $$(SRC_DIR)/out/target/product/$$(private_device)/security/wtm_rel_eden_VirtualOTP.bin $$(OUTPUT_DIR)/$$(private_product)/; fi
	$$(hide)if [ -f $$(SRC_DIR)/out/target/product/$$(private_device)/boot.img ]; then cp $$(SRC_DIR)/out/target/product/$$(private_device)/boot.img $$(OUTPUT_DIR)/$$(private_product)/; fi
	$$(hide)if [ -f $$(SRC_DIR)/out/target/product/$$(private_device)/system.img ]; then cp $$(SRC_DIR)/out/target/product/$$(private_device)/system.img $$(OUTPUT_DIR)/$$(private_product)/; fi
	$$(hide)if [ -f $$(SRC_DIR)/out/target/product/$$(private_device)/userdata.img ]; then cp $$(SRC_DIR)/out/target/product/$$(private_device)/userdata.img $$(OUTPUT_DIR)/$$(private_product)/; fi
	$$(hide)if [ -f $$(SRC_DIR)/out/target/product/$$(private_device)/ramdisk-recovery.img ]; then cp $$(SRC_DIR)/out/target/product/$$(private_device)/ramdisk-recovery.img $$(OUTPUT_DIR)/$$(private_product)/; fi
	$$(hide)if [ -f $$(SRC_DIR)/out/target/product/$$(private_device)/ramdisk.img ]; then cp $$(SRC_DIR)/out/target/product/$$(private_device)/ramdisk.img $$(OUTPUT_DIR)/$$(private_product)/; fi
	$$(hide)if [ -f $$(SRC_DIR)/out/target/product/$$(private_device)/cache.img ]; then cp $$(SRC_DIR)/out/target/product/$$(private_device)/cache.img $$(OUTPUT_DIR)/$$(private_product)/; fi
	$$(hide)if [ -d $$(SRC_DIR)/out/target/product/$$(private_device)/blf/ ]; then cp -r $$(SRC_DIR)/out/target/product/$$(private_device)/blf $$(OUTPUT_DIR)/$$(private_product)/; fi
	$$(hide)if [ -f $$(SRC_DIR)/out/target/product/$$(private_device)/primary_gpt ]; then cp $$(SRC_DIR)/out/target/product/$$(private_device)/primary_gpt $$(OUTPUT_DIR)/$$(private_product)/; fi
	$$(hide)if [ -f $$(SRC_DIR)/out/target/product/$$(private_device)/secondary_gpt ]; then cp $$(SRC_DIR)/out/target/product/$$(private_device)/secondary_gpt $$(OUTPUT_DIR)/$$(private_product)/; fi
	$$(hide)if [ -f $$(SRC_DIR)/out/target/product/$$(private_device)/System.map ]; then cp $$(SRC_DIR)/out/target/product/$$(private_device)/System.map $$(OUTPUT_DIR)/$$(private_product)/; fi
	$$(hide)if [ -f $(wildcard $$(SRC_DIR)/out/target/product/$$(private_device)/u-boot.bin*) ]; then cp $$(SRC_DIR)/out/target/product/$$(private_device)/u-boot.bin* $$(OUTPUT_DIR)/$$(private_product)/; fi
	$$(hide)if [ -f $$(SRC_DIR)/out/target/product/$$(private_device)/uImage ]; then cp $$(SRC_DIR)/out/target/product/$$(private_device)/uImage $$(OUTPUT_DIR)/$$(private_product)/uImage.android; fi
	$$(hide)if [ -f $$(SRC_DIR)/out/target/product/$$(private_device)/zImage ]; then cp $$(SRC_DIR)/out/target/product/$$(private_device)/zImage $$(OUTPUT_DIR)/$$(private_product)/; fi
	$$(hide)if [ -f $$(SRC_DIR)/out/target/product/$$(private_device)/vmlinux ]; then cp $$(SRC_DIR)/out/target/product/$$(private_device)/vmlinux $$(OUTPUT_DIR)/$$(private_product)/; fi
	$$(hide)if [ -f $$(SRC_DIR)/out/target/product/$$(private_device)/Software_Downloader.zip ]; then cp $$(SRC_DIR)/out/target/product/$$(private_device)/Software_Downloader.zip $$(OUTPUT_DIR)/; fi
	echo "    generating symbols_lib.tgz..." && \
		cp -a $$(SRC_DIR)/out/target/product/$$(private_device)/symbols/system/lib $$(OUTPUT_DIR)/$$(private_product) && \
		cd $$(OUTPUT_DIR)/$$(private_product) && tar czf symbols_lib.tgz lib && rm lib -rf
	$(log) "  done"

#$(foreach bconfig,$(boot_configs), \
#$(eval PUBLISHING_FILES+=$$(product)/u-boot.bin.$$(bconfig):m:md5)\
#)

PUBLISHING_FILES+=$$(product)/u-boot.bin:m:md5
PUBLISHING_FILES+=$$(product)/symbols_lib.tgz:o:md5
endef

define define-build-droid-otapackage
tw:=$$(subst :,  , $(1))
product:=$$(word 1, $$(tw))
device:=$$(word 2, $$(tw))
#$$(warning define-build-droid-otapackage arg1=$(1) tw=$$(tw) product=$$(product) device=$$(device))

tw:=$$(subst :,  , $(2))
os:=$$(word 1, $$(tw))
kernel_cfg:=$$(word 2, $$(tw))
#$$(warning define-build-droid-otapackage arg2=$(2) tw=$$(tw) os=$$(os) kernel_cfg=$$(kernel_cfg))

tw:=$$(subst :,  , $(3))
boot_cfg:=$$(word 1, $$(tw))
#$$(warning define-build-droid-otapackage arg3=$(3) tw=$$(tw) boot_cfg=$$(boot_cfg))

.PHONY:build_droid_otapackage_$$(product)
build_droid_otapackage_$$(product): build_droid_otapackage_$$(product)_$$(kernel_cfg)_$$(boot_cfg)

build_droid_otapackage_$$(product)_$$(kernel_cfg)_$$(boot_cfg): private_product:=$$(product)
build_droid_otapackage_$$(product)_$$(kernel_cfg)_$$(boot_cfg): private_device:=$$(device)
build_droid_otapackage_$$(product)_$$(kernel_cfg)_$$(boot_cfg): private_kcfg:=$$(kernel_cfg)
build_droid_otapackage_$$(product)_$$(kernel_cfg)_$$(boot_cfg): private_bcfg:=$$(boot_cfg)
build_droid_otapackage_$$(product)_$$(kernel_cfg)_$$(boot_cfg): output_dir
	$$(log) "starting($$(private_product) kc($$(private_kcfg)) bc($$(private_bcfg)) to build obm"
	$$(hide)cd $$(SRC_DIR) && \
	. build/envsetup.sh && \
	lunch $$(private_product)-$$(DROID_VARIANT) && \
	cd $$(SRC_DIR) && KERNEL_CONFIG=$$(private_kcfg) UBOOT_CONFIG=$$(private_bcfg) make mrvlotapackage
	$$(hide)echo "  copy OTA package ..."
	$$(hide)cp -p -r $$(SRC_DIR)/out/target/product/$$(private_device)/$$(private_product)_$$(private_kcfg)_$$(private_bcfg)-ota-mrvl.zip $$(OUTPUT_DIR)/$$(private_product)
	$$(hide)cp -p -r $$(SRC_DIR)/out/target/product/$$(private_device)/$$(private_product)_$$(private_kcfg)_$$(private_bcfg)-ota-mrvl-recovery.zip $$(OUTPUT_DIR)/$$(private_product)
	$$(hide)cp -p -r $$(SRC_DIR)/out/target/product/$$(private_device)/obj/PACKAGING/target_files_intermediates/$$(private_product)_$$(private_kcfg)_$$(private_bcfg)-target_files.zip $$(OUTPUT_DIR)/$$(private_product)/$$(private_product)_$$(private_kcfg)_$$(private_bcfg)-ota-mrvl-intermediates.zip
	$(log) "  done for OTA package build."
	$$(log) "  done."

PUBLISHING_FILES+=$$(product)/$$(product)_$$(kernel_cfg)_$$(boot_cfg)-ota-mrvl.zip:o:md5
PUBLISHING_FILES+=$$(product)/$$(product)_$$(kernel_cfg)_$$(boot_cfg)-ota-mrvl-recovery.zip:o:md5
PUBLISHING_FILES+=$$(product)/$$(product)_$$(kernel_cfg)_$$(boot_cfg)-ota-mrvl-intermediates.zip:o:md5

endef


#$1: build device
#$2: internal or external
define define-build-droid-config

tw:=$$(subst :,  , $(1))
product:=$$(word 1, $$(tw))
device:=$$(word 2, $$(tw))
#$$(warning define-build-droid-config arg1=$(1) tw=$$(tw) product=$$(product) device=$$(device))
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
#$$(warning packet-droid-nfs-config arg1=$(1) tw=$$(tw) product=$$(product) device=$$(device))
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


# <os>:<kernel_cfg>:
# os: the operating system
# kernel_cfg:kernel config file used to build the kernel
# example: android:pxa610_android_defconfig:
#
kernel_configs:=android:eden_and_defconfig:
boot_configs:=eden_concord_sharp_1080p eden_concord_otm_720p eden_concord_lg_720p

$(foreach bd,$(ABS_BUILD_DEVICES),\
	$(eval $(call define-clean-droid-kernel,$(bd)))\
	$(eval $(call define-build-droid-kernel,$(bd)))\
	$(eval $(call define-build-droid-root,$(bd)))\
	$(eval $(call define-build-droid-config,$(bd),internal))\
	$(eval $(call package-droid-nfs-config,$(bd),internal))\
)
