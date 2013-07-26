#check if the required variables have been set.
$(call check-variables, ABS_SOC ABS_DROID_BRANCH)

include $(ABS_SOC)/tools-list.mk

MY_SCRIPT_DIR:=$(ABS_TOP_DIR)/$(ABS_SOC)

DROID_TYPE:=release

ifneq ($(PLATFORM_ANDROID_VARIANT),)
       DROID_VARIANT:=$(PLATFORM_ANDROID_VARIANT)
else
       DROID_VARIANT:=userdebug
endif

KERNELSRC_TOPDIR:=kernel
DROID_OUT:=out/target/product

MAKE_EXT4FS := out/host/linux-x86/bin/make_ext4fs
MKBOOTFS := out/host/linux-x86/bin/mkbootfs
MINIGZIP := out/host/linux-x86/bin/minigzip

define define-clean-droid-kernel-target
tw:=$$(subst :,  , $(1) )
product:=$$(word 1, $$(tw) )
device:=$$(word 2, $$(tw) )
.PHONY:clean_droid_kernel_$$(product)
clean_droid_kernel_$$(product): clean_droid_$$(product) clean_kernel_$$(product)

.PHONY:clean_droid_$$(product)
clean_droid_$$(product): private_product:=$$(product)
clean_droid_$$(product): private_device:=$$(device)
clean_droid_$$(product):
	$(log) "clean android ..."
	$(hide)cd $(SRC_DIR) && \
	source ./build/envsetup.sh &&
	chooseproduct $(private_product) && choosetype $(DROID_TYPE) && choosevariant $(DROID_VARIANT) && \
	make clean
	$(log) "    done"

.PHONY:clean_kernel_$$(product)
clean_kernel_$$(product): private_product:=$$(product)
clean_kernel_$$(product): private_device:=$$(device)
clean_kernel_$$(product):
	$(log) "clean kernel ..."
	$(hide)cd $(SRC_DIR)/$(KERNELSRC_TOPDIR) && make clean
	$(log) "    done"
endef

#we need first build the android, so we get the root dir 
# and then we build the kernel images with the root dir and get the package of corresponding modules
# and then we use those module package to build corresponding android package.

define define-build-droid-kernel-target
tw:=$$(subst :,  , $(1) )
product:=$$(word 1, $$(tw) )
device:=$$(word 2, $$(tw) )
.PHONY:build_droid_kernel_$$(product)
build_droid_kernel_$$(product): build_kernel_$$(product) build_droid_$$(product) build_droid_otapackage_$$(product) build_droid_security_$$(product)
endef

MAKE_JOBS := 8
export KERNEL_TOOLCHAIN_PREFIX
export MAKE_JOBS

#$1:kernel_config
#$2:build variant
define define-build-kernel-target
tw:=$$(subst :,  , $(1) )
product:=$$(word 1, $$(tw) )
device:=$$(word 2, $$(tw) )
.PHONY: build_kernel_$$(product)

#make sure that PUBLISHING_FILES_XXX is a simply expanded variable
PUBLISHING_FILES+=$$(product)/uImage:m:md5
PUBLISHING_FILES+=$$(product)/vmlinux:o:md5
PUBLISHING_FILES+=$$(product)/System.map:o:md5
build_kernel_$$(product): private_product:=$$(product)
build_kernel_$$(product): private_device:=$$(device)
build_kernel_$$(product): output_dir
	$(log) "[$$(private_product)]starting to build kernel ..."
	$(hide)cd $(SRC_DIR) && \
	source ./build/envsetup.sh && \
	chooseproduct $$(private_product) && choosetype $(DROID_TYPE) && choosevariant $(DROID_VARIANT) && \
	cd $(SRC_DIR)/$(KERNELSRC_TOPDIR) && \
	make kernel
	$(log) "[$$(private_product)]starting to build modules ..."
	$(hide)cd $(SRC_DIR) && \
	source ./build/envsetup.sh && \
	chooseproduct $$(private_product) && choosetype $(DROID_TYPE) && choosevariant $(DROID_VARIANT) && \
	cd $(SRC_DIR)/$(KERNELSRC_TOPDIR) && \
	make modules
	$(hide)mkdir -p $(OUTPUT_DIR)/$$(private_product)
	$(hide)cp $(SRC_DIR)/$(DROID_OUT)/$$(private_device)/kernel/uImage $(OUTPUT_DIR)/$$(private_product)/
	$(hide)cp $(SRC_DIR)/$(DROID_OUT)/$$(private_device)/kernel/vmlinux $(OUTPUT_DIR)/$$(private_product)/
	$(hide)cp $(SRC_DIR)/$(DROID_OUT)/$$(private_device)/kernel/System.map $(OUTPUT_DIR)/$$(private_product)/
	$(hide)if [ -d $(OUTPUT_DIR)/$$(private_product)/modules ]; then rm -fr $(OUTPUT_DIR)/$$(private_product)/modules; fi &&\
	mkdir -p $(OUTPUT_DIR)/$$(private_product)/modules
	$(hide)cp -af $(SRC_DIR)/$(DROID_OUT)/$$(private_device)/kernel/modules  $(OUTPUT_DIR)/$$(private_product)/
	$(log) "  done."
endef

##!!## build rootfs for android, make -j4 android, copy root, copy ramdisk/userdata/system.img to outdir XXX
#$1:build variant
define define-build-droid-target
tw:=$$(subst :,  , $(1) )
product:=$$(word 1, $$(tw) )
device:=$$(word 2, $$(tw) )
.PHONY: build_droid_$$(product)
build_droid_$$(product): private_product:=$$(product)
build_droid_$$(product): private_device:=$$(device)
build_droid_$$(product): build_kernel_$$(product)
	$(log) "[$$(private_product)] building android source code ..."
	$(hide)cd $(SRC_DIR) && \
	source ./build/envsetup.sh && \
	chooseproduct $$(private_product) && choosetype $(DROID_TYPE) && choosevariant $(DROID_VARIANT) && \
	make -j8 && \
	tar zcf $(OUTPUT_DIR)/$$(private_product)/modules.tgz -C $(SRC_DIR)/$(DROID_OUT)/$$(private_device)/kernel modules && \
	tar zcf $(OUTPUT_DIR)/$$(private_product)/symbols_system.tgz -C $(SRC_DIR)/$(DROID_OUT)/$$(private_device)/ symbols

	$(hide)if [ -d $(OUTPUT_DIR)/$$(private_product)/root ]; then rm -fr $(OUTPUT_DIR)/$$(private_product)/root; fi
	$(hide)echo "  copy root directory ..." 
	$(hide)mkdir -p $(OUTPUT_DIR)/$$(private_product)
	$(hide)cp -p -r $(SRC_DIR)/$(DROID_OUT)/$$(private_device)/root $(OUTPUT_DIR)/$$(private_product)
	$(hide)cp -p -r $(SRC_DIR)/$(DROID_OUT)/$$(private_device)/ramdisk.img $(OUTPUT_DIR)/$$(private_product)
	$(hide)if [ -e $(SRC_DIR)/$(DROID_OUT)/$$(private_device)/ramdisk-recovery.img ]; then \
	cp -p -r $(SRC_DIR)/$(DROID_OUT)/$$(private_device)/ramdisk-recovery.img $(OUTPUT_DIR)/$$(private_product); \
	else \
	cp -p -r $(SRC_DIR)/$(DROID_OUT)/$$(private_device)/ramdisk.img $(OUTPUT_DIR)/$$(private_product)/ramdisk-recovery.img; fi
	$(hide)cp -p -r $(SRC_DIR)/$(DROID_OUT)/$$(private_device)/userdata.img $(OUTPUT_DIR)/$$(private_product)
	$(hide)if [ -e $(SRC_DIR)/$(DROID_OUT)/$$(private_device)/userdata_4g.img ]; then cp -p -r $(SRC_DIR)/$(DROID_OUT)/$$(private_device)/userdata_4g.img $(OUTPUT_DIR)/$$(private_product)/; fi
	$(hide)cp -p -r $(SRC_DIR)/$(DROID_OUT)/$$(private_device)/system.img $(OUTPUT_DIR)/$$(private_product)
	$(hide)cp -p -r $(SRC_DIR)/$(DROID_OUT)/$$(private_device)/system/build.prop $(OUTPUT_DIR)/$$(private_product)
	$(hide)if [ -d $(SRC_DIR)/$(DROID_OUT)/$$(private_device)/telephony/ ]; then \
	cp -p -r $(SRC_DIR)/$(DROID_OUT)/$$(private_device)/telephony/* $(OUTPUT_DIR)/$$(private_product)/; fi
	$(hide)if [ -e $(SRC_DIR)/$(DROID_OUT)/$$(private_device)/radio.img ]; then cp -p -r $(SRC_DIR)/$(DROID_OUT)/$$(private_device)/radio.img $(OUTPUT_DIR)/$$(private_product)/; fi
	$(hide)if [ -e $(SRC_DIR)/$(DROID_OUT)/$$(private_device)/radio-emei.img ]; then cp -p -r $(SRC_DIR)/$(DROID_OUT)/$$(private_device)/radio-emei.img $(OUTPUT_DIR)/$$(private_product)/; fi
	$(hide)if [ -e $(SRC_DIR)/$(DROID_OUT)/$$(private_device)/radio-kunlun.img ]; then cp -p -r $(SRC_DIR)/$(DROID_OUT)/$$(private_device)/radio-kunlun.img $(OUTPUT_DIR)/$$(private_product)/; fi
	$(hide)if [ -e $(SRC_DIR)/$(DROID_OUT)/$$(private_device)/radio-helan-td.img ]; then cp -p -r $(SRC_DIR)/$(DROID_OUT)/$$(private_device)/radio-helan-td.img $(OUTPUT_DIR)/$$(private_product)/; fi
	$(hide)if [ -e $(SRC_DIR)/$(DROID_OUT)/$$(private_device)/radio-helan-wb.img ]; then cp -p -r $(SRC_DIR)/$(DROID_OUT)/$$(private_device)/radio-helan-wb.img $(OUTPUT_DIR)/$$(private_product)/; fi
	$(hide)if [ -e $(SRC_DIR)/$(DROID_OUT)/$$(private_device)/radio-helan-wt.img ]; then cp -p -r $(SRC_DIR)/$(DROID_OUT)/$$(private_device)/radio-helan-wt.img $(OUTPUT_DIR)/$$(private_product)/; fi
	$(hide)if [ -e $(SRC_DIR)/flashing/logo.bin ]; then cp -p -r $(SRC_DIR)/flashing/logo.bin  $(OUTPUT_DIR)/$$(private_product)/; fi
	$(hide)if [ -e $(SRC_DIR)/flashing/prdcfg.bin ]; then cp -p -r $(SRC_DIR)/flashing/prdcfg.bin  $(OUTPUT_DIR)/$$(private_product)/; fi
	$(hide)if [ -e $(SRC_DIR)/flashing/factory/pxa988t7.img ]; then cp -p -r -L $(SRC_DIR)/flashing/factory/pxa988t7.img $(OUTPUT_DIR)/$$(private_product)/factory.bin; fi
	$(log) "  done"

	$(hide)if [ "$(PLATFORM_ANDROID_VARIANT)" = "user" ]; then \
	sed -i "s/ro.secure=1/ro.secure=0/" $(SRC_DIR)/$(DROID_OUT)/$$(private_device)/root/default.prop  && \
	sed -i "s/ro.debuggable=0/ro.debuggable=1/" $(SRC_DIR)/$(DROID_OUT)/$$(private_device)/root/default.prop  && \
	cd $(SRC_DIR)/$(DROID_OUT)/$$(private_device) && \
	$(SRC_DIR)/$(MKBOOTFS) root | $(SRC_DIR)/$(MINIGZIP) > ramdisk-rooted.img && \
	cat ramdisk-rooted.img < /dev/zero | head -c 1048576 > ramdisk-rooted.img.pad && \
	cp -p -r $(SRC_DIR)/$(DROID_OUT)/$$(private_device)/ramdisk-rooted.img.pad $(OUTPUT_DIR)/$$(private_product)/ramdisk-rooted.img && \
	touch $(OUTPUT_DIR)/product_mode_build.txt; fi

##!!## first time publish: all for two
PUBLISHING_FILES+=$$(product)/userdata.img:m:md5
PUBLISHING_FILES+=$$(product)/userdata_4g.img:o:md5
PUBLISHING_FILES+=$$(product)/system.img:m:md5
PUBLISHING_FILES+=$$(product)/ramdisk.img:m:md5
PUBLISHING_FILES+=$$(product)/ramdisk-rooted.img:o:md5
PUBLISHING_FILES+=$$(product)/symbols_system.tgz:o:md5
PUBLISHING_FILES+=$$(product)/ramdisk-recovery.img:o:md5
PUBLISHING_FILES+=$$(product)/build.prop:o:md5
PUBLISHING_FILES+=$$(product)/modules.tgz:o:md5
PUBLISHING_FILES+=product_mode_build.txt:o

PUBLISHING_FILES+=$$(product)/pxafs.img:o:md5
PUBLISHING_FILES+=$$(product)/pxa_symbols.tgz:o:md5
PUBLISHING_FILES+=$$(product)/radio.img:o:md5
PUBLISHING_FILES+=$$(product)/radio-emei.img:o:md5
PUBLISHING_FILES+=$$(product)/radio-kunlun.img:o:md5
PUBLISHING_FILES+=$$(product)/nvm-emei.img:o:md5
PUBLISHING_FILES+=$$(product)/nvm-kunlun.img:o:md5
PUBLISHING_FILES+=$$(product)/nvm-helan-td.img:o:md5

PUBLISHING_FILES+=$$(product)/HL_CP.bin:o:md5
PUBLISHING_FILES+=$$(product)/EM_CP.bin:o:md5
PUBLISHING_FILES+=$$(product)/EM_CP_DIAG.mdb:o:md5
PUBLISHING_FILES+=$$(product)/EM_CP_NVM.mdb:o:md5
PUBLISHING_FILES+=$$(product)/EM_M08_AI_Z1_Flash.bin:o:md5
PUBLISHING_FILES+=$$(product)/HL_M08_AI_Z1_Flash.bin:o:md5
PUBLISHING_FILES+=$$(product)/KL_CP.bin:o:md5
PUBLISHING_FILES+=$$(product)/KL_CP_DIAG.mdb:o:md5
PUBLISHING_FILES+=$$(product)/KL_CP_NVM.mdb:o:md5
PUBLISHING_FILES+=$$(product)/KUNLUN_Z0_M14_AI_Flash.bin:o:md5
PUBLISHING_FILES+=$$(product)/KUNLUN_A0_M15_AI_Flash.bin:o:md5

PUBLISHING_FILES+=$$(product)/KUNLUN_Arbel.bin:o:md5
PUBLISHING_FILES+=$$(product)/KUNLUN_Arbel_DIAG.mdb:o:md5
PUBLISHING_FILES+=$$(product)/KUNLUN_Arbel_NVM.mdb:o:md5

PUBLISHING_FILES+=$$(product)/HL_TD_CP.bin:o:md5
PUBLISHING_FILES+=$$(product)/HL_TD_CP_DIAG.mdb:o:md5
PUBLISHING_FILES+=$$(product)/HL_TD_CP_NVM.mdb:o:md5
PUBLISHING_FILES+=$$(product)/HL_TD_M08_AI_A0_Flash.bin:o:md5
PUBLISHING_FILES+=$$(product)/radio-helan-td.img:o:md5
PUBLISHING_FILES+=$$(product)/HELAN_A0_M16_AI_Flash.bin:o:md5
PUBLISHING_FILES+=$$(product)/HL_WB_CP.bin:o:md5
PUBLISHING_FILES+=$$(product)/HL_WB_CP_DIAG.mdb:o:md5
PUBLISHING_FILES+=$$(product)/HL_WB_CP_NVM.mdb:o:md5
PUBLISHING_FILES+=$$(product)/HLWT_TD_CP.bin:o:md5
PUBLISHING_FILES+=$$(product)/HLWT_TD_CP_DIAG.mdb:o:md5
PUBLISHING_FILES+=$$(product)/HLWT_TD_CP_NVM.mdb:o:md5
PUBLISHING_FILES+=$$(product)/HLWT_TD_M08_AI_A0_Flash.bin:o:md5
PUBLISHING_FILES+=$$(product)/nvm-helan-wb.img:o:md5
PUBLISHING_FILES+=$$(product)/nvm-helan-wt.img:o:md5
PUBLISHING_FILES+=$$(product)/radio-helan-wb.img:o:md5
PUBLISHING_FILES+=$$(product)/radio-helan-wt.img:o:md5

PUBLISHING_FILES+=$$(product)/TABLET_CP.bin:o:md5
PUBLISHING_FILES+=$$(product)/TABLET_MSA.bin:o:md5

PUBLISHING_FILES+=$$(product)/KL_DSDS_CP.bin:o:md5
PUBLISHING_FILES+=$$(product)/KL_DSDS_CP_DIAG.mdb:o:md5
PUBLISHING_FILES+=$$(product)/KL_DSDS_CP_NVM.mdb:o:md5
PUBLISHING_FILES+=$$(product)/KUNLUN_A0_M15_AI_DSDS_Flash.bin:o:md5
PUBLISHING_FILES+=$$(product)/KUNLUN_Z0_M14_AI_DSDS_Flash.bin:o:md5

PUBLISHING_FILES+=$$(product)/WK_CP_2CHIP_SPRW_NVM.mdb:o:md5
PUBLISHING_FILES+=$$(product)/WK_CP_2CHIP_SPRW_DIAG.mdb:o:md5
PUBLISHING_FILES+=$$(product)/Boerne_DIAG.mdb.txt:o:md5
PUBLISHING_FILES+=$$(product)/ReliableData.bin:o:md5

PUBLISHING_FILES+=$$(product)/logo.bin:o:md5
PUBLISHING_FILES+=$$(product)/prdcfg.bin:o:md5
PUBLISHING_FILES+=$$(product)/factory.bin:o:md5

ifeq ($(product),pxa988dkb_def)
PUBLISHING_FILES+=$$(product)/Arbel_DIGRF3_NVM.mdb:o:md5
PUBLISHING_FILES+=$$(product)/Arbel_DIGRF3.bin:o:md5
PUBLISHING_FILES+=$$(product)/Arbel_DIGRF3_DIAG.mdb:o:md5
PUBLISHING_FILES+=$$(product)/Arbel_DKB_SKWS.bin:o:md5
PUBLISHING_FILES+=$$(product)/Arbel_DKB_SKWS_NVM.mdb:o:md5
PUBLISHING_FILES+=$$(product)/Arbel_DKB_SKWS_DIAG.mdb:o:md5
PUBLISHING_FILES+=$$(product)/TTD_M06_AI_A0_Flash.bin:o:md5
PUBLISHING_FILES+=$$(product)/TTD_M06_AI_A1_Flash.bin:o:md5
PUBLISHING_FILES+=$$(product)/TTD_M06_AI_Y0_Flash.bin:o:md5
PUBLISHING_FILES+=$$(product)/WK_CP_2CHIP_SPRW.bin:o:md5
PUBLISHING_FILES+=$$(product)/WK_M08_AI_Y1_removelo_Y0_Flash.bin:o:md5
endif
endef

ifneq ($(ABS_DROID_BRANCH),other)
define define-build-droid-otapackage
tw:=$$(subst :,  , $(1) )
product:=$$(word 1, $$(tw) )
device:=$$(word 2, $$(tw) )
.PHONY: build_droid_otapackage_$$(product)
build_droid_otapackage_$$(product): private_product:=$$(product)
build_droid_otapackage_$$(product): private_device:=$$(device)
build_droid_otapackage_$$(product): build_uboot_obm_$$(product)
	$(log) "[$$(private_product)] building android OTA package ..."
	$(hide)cd $(SRC_DIR) && \
	source ./build/envsetup.sh && \
	chooseproduct $$(private_product) && choosetype $(DROID_TYPE) && choosevariant $(DROID_VARIANT) && \
	make mrvlotapackage
	$(hide)echo "  copy OTA package ..."
	$(hide)cp -p -r $(SRC_DIR)/$(DROID_OUT)/$$(private_device)/$$(private_product)-ota-mrvl.zip $(OUTPUT_DIR)/$$(private_product)
	$(hide)cp -p -r $(SRC_DIR)/$(DROID_OUT)/$$(private_device)/$$(private_product)-ota-mrvl-recovery.zip $(OUTPUT_DIR)/$$(private_product)
	$(hide)cp -p -r $(SRC_DIR)/$(DROID_OUT)/$$(private_device)/obj/PACKAGING/target_files_intermediates/$$(private_product)-target_files-eng.$$(USER).zip $(OUTPUT_DIR)/$$(private_product)/$$(private_product)-ota-mrvl-intermediates.zip
	$(log) "  done for OTA package build."

PUBLISHING_FILES+=$$(product)/$$(product)-ota-mrvl.zip:o:md5
PUBLISHING_FILES+=$$(product)/$$(product)-ota-mrvl-recovery.zip:o:md5
PUBLISHING_FILES+=$$(product)/$$(product)-ota-mrvl-intermediates.zip:o:md5

endef
else
define define-build-droid-otapackage
tw:=$$(subst :,  , $(1) )
product:=$$(word 1, $$(tw) )
device:=$$(word 2, $$(tw) )
.PHONY: build_droid_otapackage_$$(product)
build_droid_otapackage_$$(product): private_product:=$$(product)
build_droid_otapackage_$$(product): private_device:=$$(device)
build_droid_otapackage_$$(product): build_uboot_obm_$$(product)
	$(log) "[$$(private_product)] no android OTA package build ..."
endef
endif

define define-build-droid-tool
tw:=$$(subst :,  , $(1) )
product:=$$(word 1, $$(tw) )
device:=$$(word 2, $$(tw) )
.PHONY: build_droid_tool_$$(product)
build_droid_tool_$$(product): private_product:=$$(product)
build_droid_tool_$$(product): private_device:=$$(device)
build_droid_tool_$$(product): build_droid_$$(product)
	$(log) "[$$(private_product)] rebuilding android source code with eng for tools ..."
	$(hide)cd $(SRC_DIR) && \
	source ./build/envsetup.sh && \
	chooseproduct $$(private_product) && choosetype $(DROID_TYPE) && choosevariant eng && \
	make -j8
	$(hide)if [ -d $(SRC_DIR)/$(DROID_OUT)/$$(private_device)/tools ]; then rm -fr $(SRC_DIR)/$(DROID_OUT)/$$(private_device)/tools; fi
	$(hide)echo "  copy and make tools image ..."
	$(hide)mkdir -p $(SRC_DIR)/$(DROID_OUT)/$$(private_device)/tools/bin
	$(hide)cd $(SRC_DIR)/$(DROID_OUT)/$$(private_device)/symbols/system && \
	cp -af $(TOOLS_LIST) $(SRC_DIR)/$(DROID_OUT)/$$(private_device)/tools/bin
	$(hide)$(SRC_DIR)/$(MAKE_EXT4FS) -s -l 65536k -b 1024 -L tool $(SRC_DIR)/$(DROID_OUT)/$$(private_device)/tools.img $(SRC_DIR)/$(DROID_OUT)/$$(private_device)/tools
	$(hide)cp -p -r $(SRC_DIR)/$(DROID_OUT)/$$(private_device)/tools.img $(OUTPUT_DIR)/$$(private_product)/
	tar zcvf $(OUTPUT_DIR)/$$(private_product)/tools.tgz -C $(SRC_DIR)/$(DROID_OUT)/$$(private_device) tools

PUBLISHING_FILES+=$$(product)/tools.img:o:md5
PUBLISHING_FILES+=$$(product)/tools.tgz:o:md5

endef

ifneq ($(ABS_DROID_BRANCH),jb4.2)
define define-build-droid-security
tw:=$$(subst :,  , $(1) )
product:=$$(word 1, $$(tw) )
device:=$$(word 2, $$(tw) )
.PHONY: build_droid_security_$$(product)
build_droid_security_$$(product): private_product:=$$(product)
build_droid_security_$$(product): private_device:=$$(device)
build_droid_security_$$(product): build_droid_$$(product)
	$(log) "[$$(private_product)] building security ..."
	$(hide)cd $(SRC_DIR) && \
	source ./build/envsetup.sh && \
	chooseproduct $$(private_product) && choosetype $(DROID_TYPE) && choosevariant $(DROID_VARIANT) && \
	cd vendor/marvell/generic/security && \
	git reset --hard HEAD && git checkout shgit/security-1_0 && mm -B && \
	cd $(SRC_DIR)/vendor/marvell/generic/security/wtpsp/drv/src && \
	make KDIR=$(SRC_DIR)/kernel/kernel ARCH=arm CROSS_COMPILE=arm-eabi- M=$(PWD) && cp -a geu.ko $(SRC_DIR)/$(DROID_OUT)/$$(private_device)/system/lib/modules && \
	cd $(SRC_DIR)/$(DROID_OUT)/$$(private_device) && \
	tar zcvf $(OUTPUT_DIR)/$$(private_product)/security.tgz system/lib/libparseTim.so system/lib/libwtpsp.so system/lib/libwtpsp_ss.so system/lib/modules/geu.ko && \
	cd $(SRC_DIR)

PUBLISHING_FILES+=$$(product)/security.tgz:o:md5

endef
else
define define-build-droid-security
tw:=$$(subst :,  , $(1) )
product:=$$(word 1, $$(tw) )
device:=$$(word 2, $$(tw) )
.PHONY: build_droid_security_$$(product)
build_droid_security_$$(product): private_product:=$$(product)
build_droid_security_$$(product): private_device:=$$(device)
build_droid_security_$$(product): build_droid_$$(product)
	$(log) "[$$(private_product)] no security build ..."

endef
endif

$(foreach bv,$(ABS_BUILD_DEVICES), $(eval $(call define-build-droid-kernel-target,$(bv)) )\
				$(eval $(call define-build-kernel-target,$(bv)) ) \
				$(eval $(call define-build-droid-target,$(bv)) ) \
				$(eval $(call define-clean-droid-kernel-target,$(bv)) ) \
				$(eval $(call define-build-droid-otapackage,$(bv)) ) \
				$(eval $(call define-build-droid-security,$(bv)) ) \
)
