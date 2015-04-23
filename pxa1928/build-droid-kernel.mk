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
PUBLISHING_FILES2+=$$(product)/boot.img:./$$(product)/flash/:o:md5
PUBLISHING_FILES2+=$$(product)/system.img:./$$(product)/flash/:m:md5
PUBLISHING_FILES2+=$$(product)/userdata.img:./$$(product)/flash/:o:md5
PUBLISHING_FILES2+=$$(product)/ramdisk.img:./$$(product)/debug/:o:md5
PUBLISHING_FILES2+=$$(product)/ramdisk-recovery.img:./$$(product)/debug/:o:md5
PUBLISHING_FILES2+=$$(product)/cache.img:./$$(product)/flash/:o:md5
PUBLISHING_FILES2+=$$(product)/primary_gpt:./$$(product)/flash/:o:md5
PUBLISHING_FILES2+=$$(product)/secondary_gpt:./$$(product)/flash/:o:md5
PUBLISHING_FILES2+=$$(product)/System.map:./$$(product)/debug/:o:md5
PUBLISHING_FILES2+=$$(product)/uImage.android:./$$(product)/debug/:o:md5
PUBLISHING_FILES2+=$$(product)/zImage:./$$(product)/debug/:o:md5
PUBLISHING_FILES2+=$$(product)/vmlinux:./$$(product)/debug/:o:md5
PUBLISHING_FILES2+=$$(product)/build.prop:./$$(product)/debug/:o:md5
PUBLISHING_FILES2+=$$(product)/pxa1928concord.dtb:./$$(product)/debug/:o:md5
PUBLISHING_FILES2+=$$(product)/pxa1928concord-discrete.dtb:./$$(product)/debug/:o:md5
PUBLISHING_FILES2+=$$(product)/pxa1928ff.dtb:./$$(product)/debug/:o:md5
PUBLISHING_FILES2+=$$(product)/blf:./$$(product)/flash/:o:md5
PUBLISHING_FILES2+=$$(product)/u-boot.bin:./$$(product)/flash/:o:md5
PUBLISHING_FILES2+=$$(product)/obm_trusted_tz.bin:./$$(product)/flash/:o:md5
PUBLISHING_FILES2+=$$(product)/obm_trusted_tz_auto.bin:./$$(product)/debug/:o:md5
PUBLISHING_FILES2+=Software_Downloader.zip:./:m:md5
ifeq ($(filter $$(device),pxa1928ff),)
PUBLISHING_FILES2+=$$(product)/primary_gpt_8g:./$$(product)/flash/:o:md5
PUBLISHING_FILES2+=$$(product)/secondary_gpt_8g:./$$(product)/flash/:o:md5
PUBLISHING_FILES2+=$$(product)/userdata_8g.img:./$$(product)/flash/:o:md5
endif

PUBLISHING_FILES2+=$$(product)/Boerne_DIAG.mdb.txt:./$$(product)/debug/:o:md5
PUBLISHING_FILES2+=$$(product)/HL_SS_M09_Y0_AI_SKL_Flash.bin:./$$(product)/flash/:o:md5
PUBLISHING_FILES2+=$$(product)/HL_SS_M09_Y0_AI_SKL_Flash_B0.bin:./$$(product)/flash/:o:md5
PUBLISHING_FILES2+=$$(product)/HL_LTG_SL_DKB.bin:./$$(product)/flash/:o:md5
PUBLISHING_FILES2+=$$(product)/HL_LTG_SL_DKB_B0.bin:./$$(product)/flash/:o:md5
PUBLISHING_FILES2+=$$(product)/HL_LTG_SL_DKB_NVM.mdb:./$$(product)/debug/:o:md5
PUBLISHING_FILES2+=$$(product)/HL_LTG_SL_DKB_B0_NVM.mdb:./$$(product)/debug/:o:md5
PUBLISHING_FILES2+=$$(product)/HL_LTG_SL_DKB_DIAG.mdb:./$$(product)/debug/:o:md5
PUBLISHING_FILES2+=$$(product)/HL_LTG_SL_DKB_B0_DIAG.mdb:./$$(product)/debug/:o:md5
PUBLISHING_FILES2+=$$(product)/HL_LWG_DKB.bin:./$$(product)/flash/:o:md5
PUBLISHING_FILES2+=$$(product)/HL_LWG_DKB_B0.bin:./$$(product)/flash/:o:md5
PUBLISHING_FILES2+=$$(product)/HL_LWG_DKB_DIAG.mdb:./$$(product)/debug/:o:md5
PUBLISHING_FILES2+=$$(product)/HL_LWG_DKB_B0_DIAG.mdb:./$$(product)/debug/:o:md5
PUBLISHING_FILES2+=$$(product)/HL_LWG_DKB_NVM.mdb:./$$(product)/debug/:o:md5
PUBLISHING_FILES2+=$$(product)/HL_LWG_DKB_B0_NVM.mdb:./$$(product)/debug/:o:md5
PUBLISHING_FILES2+=$$(product)/HL_LWG_M09_B0_SKL_Flash.bin:./$$(product)/flash/:o:md5
PUBLISHING_FILES2+=$$(product)/HL_LWG_M09_B0_SKL_Flash_B0.bin:./$$(product)/flash/:o:md5
PUBLISHING_FILES2+=$$(product)/HL_LTG_SL_DKB_MDB.bin:./$$(product)/flash/:o:md5
PUBLISHING_FILES2+=$$(product)/HL_LTG_SL_DKB_B0_MDB.bin:./$$(product)/flash/:o:md5
PUBLISHING_FILES2+=$$(product)/HL_LWG_DKB_MDB.bin:./$$(product)/flash/:o:md5
PUBLISHING_FILES2+=$$(product)/HL_LWG_DKB_B0_MDB.bin:./$$(product)/flash/:o:md5
PUBLISHING_FILES2+=$$(product)/Skylark_LTG.bin:./$$(product)/flash/:o:md5
PUBLISHING_FILES2+=$$(product)/Skylark_LTG_B0.bin:./$$(product)/flash/:o:md5
PUBLISHING_FILES2+=$$(product)/Skylark_LTG_B0_V13.bin:./$$(product)/flash/:o:md5
PUBLISHING_FILES2+=$$(product)/Skylark_LTG_B0_V15.bin:./$$(product)/flash/:o:md5
PUBLISHING_FILES2+=$$(product)/Skylark_LWG.bin:./$$(product)/flash/:o:md5
PUBLISHING_FILES2+=$$(product)/Skylark_LWG_B0.bin:./$$(product)/flash/:o:md5
PUBLISHING_FILES2+=$$(product)/Skylark_LWG_B0_V13.bin:./$$(product)/flash/:o:md5
PUBLISHING_FILES2+=$$(product)/Skylark_LWG_B0_V15.bin:./$$(product)/flash/:o:md5
PUBLISHING_FILES2+=$$(product)/persistent.img:./$$(product)/flash/:o:md5

ifeq ($(filter $(ABS_DROID_BRANCH),aosp pdk5.0 lmr1 lmr1_32),)
PUBLISHING_FILES2+=$$(product)/recovery.img:./$$(product)/flash/:o:md5
PUBLISHING_FILES2+=$$(product)/tee_tw.bin:./$$(product)/flash/:o:md5
PUBLISHING_FILES2+=$$(product)/teesst.img:./$$(product)/flash/:o:md5
PUBLISHING_FILES2+=$$(product)/wtm_rel_eden_RealOTP.bin:./$$(product)/flash/:o:md5
PUBLISHING_FILES2+=$$(product)/wtm_rel_eden_VirtualOTP.bin:./$$(product)/flash/:o:md5
PUBLISHING_FILES2+=$$(product)/nvm.img:./$$(product)/flash/:o:md5
PUBLISHING_FILES2+=$$(product)/ReliableData.bin:./$$(product)/flash/:o:md5
ifeq ($(filter $$(device),pxa1928ff),)
PUBLISHING_FILES2+=$$(product)/EDEN_LWG_M09_B0_CP6X_DSDS_SKL_Flash.bin:./$$(product)/flash/:o:md5
PUBLISHING_FILES2+=$$(product)/HL_LWG_DKB_B0_CP6X.bin:./$$(product)/flash/:o:md5
PUBLISHING_FILES2+=$$(product)/HL_LWG_DKB_B0_CP6X_MDB.bin:./$$(product)/flash/:o:md5
PUBLISHING_FILES2+=$$(product)/Skylark_LWG_B0_CMCC_CP6X.bin:./$$(product)/flash/:o:md5
PUBLISHING_FILES2+=$$(product)/Skylark_LWG_B0_EU_CP6X.bin:./$$(product)/flash/:o:md5
PUBLISHING_FILES2+=$$(product)/Skylark_LWG_B0_NA_CP6X.bin:./$$(product)/flash/:o:md5
PUBLISHING_FILES2+=$$(product)/HL_LWG_DKB_B0_CP6X_MDB.txt:./$$(product)/debug/:o:md5
PUBLISHING_FILES2+=$$(product)/CP6X_version.txt:./$$(product)/debug/:o:md5
endif
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
	$$(hide)if [ -f $(wildcard $$(SRC_DIR)/out/target/product/$$(private_device)/userdata*.img) ]; then cp $$(SRC_DIR)/out/target/product/$$(private_device)/userdata*.img $$(OUTPUT_DIR)/$$(private_product)/; fi
	$$(hide)if [ -f $$(SRC_DIR)/out/target/product/$$(private_device)/ramdisk-recovery.img ]; then cp $$(SRC_DIR)/out/target/product/$$(private_device)/ramdisk-recovery.img $$(OUTPUT_DIR)/$$(private_product)/; fi
	$$(hide)if [ -f $$(SRC_DIR)/out/target/product/$$(private_device)/recovery.img ]; then cp $$(SRC_DIR)/out/target/product/$$(private_device)/recovery.img $$(OUTPUT_DIR)/$$(private_product)/; fi
	$$(hide)if [ -f $$(SRC_DIR)/out/target/product/$$(private_device)/ramdisk.img ]; then cp $$(SRC_DIR)/out/target/product/$$(private_device)/ramdisk.img $$(OUTPUT_DIR)/$$(private_product)/; fi
	$$(hide)if [ -f $$(SRC_DIR)/out/target/product/$$(private_device)/cache.img ]; then cp $$(SRC_DIR)/out/target/product/$$(private_device)/cache.img $$(OUTPUT_DIR)/$$(private_product)/; fi
	$$(hide)if [ -d $$(SRC_DIR)/out/target/product/$$(private_device)/blf/ ]; then cp -r $$(SRC_DIR)/out/target/product/$$(private_device)/blf $$(OUTPUT_DIR)/$$(private_product)/; fi
	$$(hide)if [ -f $(wildcard $$(SRC_DIR)/out/target/product/$$(private_device)/primary_gpt*) ]; then cp $$(SRC_DIR)/out/target/product/$$(private_device)/primary_gpt* $$(OUTPUT_DIR)/$$(private_product)/; fi
	$$(hide)if [ -f $(wildcard $$(SRC_DIR)/out/target/product/$$(private_device)/secondary_gpt*) ]; then cp $$(SRC_DIR)/out/target/product/$$(private_device)/secondary_gpt* $$(OUTPUT_DIR)/$$(private_product)/; fi
	$$(hide)if [ -d $$(SRC_DIR)/out/target/product/$$(private_device)/telephony/ ]; then cp -p -r $$(SRC_DIR)/out/target/product/$$(private_device)/telephony/* $$(OUTPUT_DIR)/$$(private_product)/; fi
	$$(hide)if [ -f $$(SRC_DIR)/out/target/product/$$(private_device)/System.map ]; then cp $$(SRC_DIR)/out/target/product/$$(private_device)/System.map $$(OUTPUT_DIR)/$$(private_product)/; fi
	$$(hide)if [ -f $(wildcard $$(SRC_DIR)/out/target/product/$$(private_device)/u-boot.bin*) ]; then cp $$(SRC_DIR)/out/target/product/$$(private_device)/u-boot.bin* $$(OUTPUT_DIR)/$$(private_product)/; fi
	$$(hide)if [ -f $(wildcard $$(SRC_DIR)/out/target/product/$$(private_device)/obm_trusted_tz*.bin) ]; then cp $$(SRC_DIR)/out/target/product/$$(private_device)/obm_trusted_tz*.bin $$(OUTPUT_DIR)/$$(private_product)/; fi
	$$(hide)if [ -f $$(SRC_DIR)/out/target/product/$$(private_device)/uImage ]; then cp $$(SRC_DIR)/out/target/product/$$(private_device)/uImage $$(OUTPUT_DIR)/$$(private_product)/uImage.android; fi
	$$(hide)if [ -f $$(SRC_DIR)/out/target/product/$$(private_device)/zImage ]; then cp $$(SRC_DIR)/out/target/product/$$(private_device)/zImage $$(OUTPUT_DIR)/$$(private_product)/; fi
	$$(hide)if [ -f $$(SRC_DIR)/out/target/product/$$(private_device)/vmlinux ]; then cp $$(SRC_DIR)/out/target/product/$$(private_device)/vmlinux $$(OUTPUT_DIR)/$$(private_product)/; fi
	$$(hide)if [ -f $$(SRC_DIR)/out/target/product/$$(private_device)/system/build.prop ]; then cp $$(SRC_DIR)/out/target/product/$$(private_device)/system/build.prop $$(OUTPUT_DIR)/$$(private_product)/debug; fi
	$$(hide)if [ -f $$(SRC_DIR)/out/target/product/$$(private_device)/persistent.img ]; then cp $$(SRC_DIR)/out/target/product/$$(private_device)/persistent.img $$(OUTPUT_DIR)/$$(private_product)/; fi
	$$(hide)if [ -f $$(SRC_DIR)/out/target/product/$$(private_device)/pxa1928concord.dtb ]; then cp $$(SRC_DIR)/out/target/product/$$(private_device)/pxa1928concord.dtb $$(OUTPUT_DIR)/$$(private_product)/; fi
	$$(hide)if [ -f $$(SRC_DIR)/out/target/product/$$(private_device)/pxa1928concord-discrete.dtb ]; then cp $$(SRC_DIR)/out/target/product/$$(private_device)/pxa1928concord-discrete.dtb $$(OUTPUT_DIR)/$$(private_product)/; fi
	$$(hide)if [ -f $$(SRC_DIR)/out/target/product/$$(private_device)/pxa1928ff.dtb ]; then cp $$(SRC_DIR)/out/target/product/$$(private_device)/pxa1928ff.dtb $$(OUTPUT_DIR)/$$(private_product)/; fi
	$$(hide)if [ -f $$(SRC_DIR)/out/target/product/$$(private_device)/Software_Downloader.zip ]; then cp $$(SRC_DIR)/out/target/product/$$(private_device)/Software_Downloader.zip $$(OUTPUT_DIR)/; fi
	echo "    generating symbols_system.tgz..." && \
		cp -a $$(SRC_DIR)/out/target/product/$$(private_device)/symbols/system $$(OUTPUT_DIR)/$$(private_product) && \
		cd $$(OUTPUT_DIR)/$$(private_product) && tar czf symbols_system.tgz system && rm system -rf
	$(log) "  done"

PUBLISHING_FILES2+=$$(product)/symbols_system.tgz:./$$(product)/debug/:o:md5
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
ifneq ($(filter $(ABS_DROID_BRANCH),aosp pdk5.0 lmr1 lmr1_32),)
	$$(log) "disalbe otapackage build by generating fake ota files temporally"
	$$(hide)touch $$(OUTPUT_DIR)/$$(private_product)/$$(private_product)-ota-mrvl.zip
	$$(hide)touch $$(OUTPUT_DIR)/$$(private_product)/$$(private_product)-ota-mrvl-recovery.zip
	$$(hide)touch $$(OUTPUT_DIR)/$$(private_product)/$$(private_product)-ota-mrvl-intermediates.zip
else
	$$(log) "starting($$(private_product) kc($$(private_kcfg)) bc($$(private_bcfg)) to build mrvlotapackage"
	$$(hide)cd $$(SRC_DIR) && \
	. build/envsetup.sh && \
	lunch $$(private_product)-$$(DROID_VARIANT) && \
	cd $$(SRC_DIR) && KERNEL_CONFIG=$$(private_kcfg) UBOOT_CONFIG=$$(private_bcfg) make mrvlotapackage
	$$(hide)echo "  copy OTA package ..."

	$$(hide)cp -p -r $$(SRC_DIR)/out/target/product/$$(private_device)/$$(private_product)-ota-mrvl.zip $$(OUTPUT_DIR)/$$(private_product)
	$$(hide)cp -p -r $$(SRC_DIR)/out/target/product/$$(private_device)/$$(private_product)-ota-mrvl-recovery.zip $$(OUTPUT_DIR)/$$(private_product)
	$$(hide)cp -p -r $$(SRC_DIR)/out/target/product/$$(private_device)/obj/PACKAGING/target_files_intermediates/$$(private_product)-target_files.zip $$(OUTPUT_DIR)/$$(private_product)/$$(private_product)-ota-mrvl-intermediates.zip
endif
	$(log) "  done for OTA package build."
	$$(log) "  done."

PUBLISHING_FILES2+=$$(product)/$$(product)-ota-mrvl.zip:./$$(product)/ota/:o:md5
PUBLISHING_FILES2+=$$(product)/$$(product)-ota-mrvl-recovery.zip:./$$(product)/ota/:o:md5
PUBLISHING_FILES2+=$$(product)/$$(product)-ota-mrvl-intermediates.zip:./$$(product)/ota/:o:md5
PUBLISHING_FILES2+=$$(product)/target_files-package.zip:./$$(product)/ota/:o:md5

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
PUBLISHING_FILES2+=$$(product)/root_nfs_$(2).tgz:./$$(product)/debug/:m:md5

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
define define-build-init
tw:=$$(subst :,  , $(1))
product:=$$(word 1, $$(tw))
device:=$$(word 2, $$(tw))
kernel_configs:=android:defconfig:
boot_configs:=pxa1928_concord_config
endef

$(foreach bd,$(ABS_BUILD_DEVICES),\
	$(eval $(call define-build-init,$(bd)))\
	$(eval $(call define-clean-droid-kernel,$(bd)))\
	$(eval $(call define-build-droid-kernel,$(bd)))\
	$(eval $(call define-build-droid-root,$(bd)))\
	$(foreach kc,$(kernel_configs),\
		$(foreach bc,$(boot_configs),\
			$(eval $(call define-build-droid-otapackage,$(bd),$(kc),$(bc)))))\
	$(eval $(call define-build-droid-config,$(bd),internal))\
	$(eval $(call package-droid-nfs-config,$(bd),internal))\
)
