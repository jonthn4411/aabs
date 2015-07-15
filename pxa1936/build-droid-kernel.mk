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
build_droid_kernel_$$(product): build_droid_$$(product) build_droid_otapackage_$$(product) build_debug_kernel_$$(product) build_droid_debug_img_$$(product)
endef

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
PUBLISHING_FILES2+=$$(product)/uImage:./$$(product)/debug/:m:md5
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

	$(hide)if [ -d $(OUTPUT_DIR)/$$(private_product)/dtb ]; then rm -fr $(OUTPUT_DIR)/$$(private_product)/dtb; fi &&\
	mkdir -p $(OUTPUT_DIR)/$$(private_product)/dtb
	$(hide)cp -af $(SRC_DIR)/$(DROID_OUT)/$$(private_device)/*.dtb  $(OUTPUT_DIR)/$$(private_product)/dtb/

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
build_droid_$$(product): 
	$(log) "[$$(private_product)] building android source code ..."
	$(hide)if [ -d $(SRC_DIR)/$(DROID_OUT)/$$(private_device) ]; then rm -fr $(SRC_DIR)/$(DROID_OUT)/$$(private_device); fi
	mkdir -p $(OUTPUT_DIR)/$$(private_product)
	$(hide)cd $(SRC_DIR) && \
	source ./build/envsetup.sh && \
	chooseproduct $$(private_product) && choosetype $(DROID_TYPE) && choosevariant $(DROID_VARIANT) && \
	make -j$$(MAKE_JOBS) && \
	tar zcf $(OUTPUT_DIR)/$$(private_product)/symbols_system.tgz -C $(SRC_DIR)/$(DROID_OUT)/$$(private_device)/ symbols
	$(hide)if [ -d $(SRC_DIR)/$(DROID_OUT)/$$(private_device)/debug_kmodules ]; then \
	tar zcf $(OUTPUT_DIR)/$$(private_product)/modules.tgz -C $(SRC_DIR)/$(DROID_OUT)/$$(private_device)/debug_kmodules/lib modules; fi
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
	$(hide)if [ -e $(SRC_DIR)/$(DROID_OUT)/$$(private_device)/userdata_8g.img ]; then cp -p -r $(SRC_DIR)/$(DROID_OUT)/$$(private_device)/userdata_8g.img $(OUTPUT_DIR)/$$(private_product)/; fi
	$(hide)if [ -e $(SRC_DIR)/$(DROID_OUT)/$$(private_device)/primary_gpt_8g ]; then cp -p -r $(SRC_DIR)/$(DROID_OUT)/$$(private_device)/primary_gpt_8g $(OUTPUT_DIR)/$$(private_product)/; fi
	$(hide)if [ -e $(SRC_DIR)/$(DROID_OUT)/$$(private_device)/secondary_gpt_8g ]; then cp -p -r $(SRC_DIR)/$(DROID_OUT)/$$(private_device)/secondary_gpt_8g $(OUTPUT_DIR)/$$(private_product)/; fi
	$(hide)cp -p -r $(SRC_DIR)/$(DROID_OUT)/$$(private_device)/system.img $(OUTPUT_DIR)/$$(private_product)
	$(hide)cp -p -r $(SRC_DIR)/$(DROID_OUT)/$$(private_device)/system/build.prop $(OUTPUT_DIR)/$$(private_product)
	$(hide)if [ -d $(SRC_DIR)/$(DROID_OUT)/$$(private_device)/telephony/ ]; then \
	cp -p -r $(SRC_DIR)/$(DROID_OUT)/$$(private_device)/telephony/* $(OUTPUT_DIR)/$$(private_product)/; fi
	$(hide)if [ -d $(SRC_DIR)/$(DROID_OUT)/$$(private_device)/security/ ]; then \
	cp -p -r $(SRC_DIR)/$(DROID_OUT)/$$(private_device)/security/* $(OUTPUT_DIR)/$$(private_product)/; fi
	$(hide)if [ -d $(SRC_DIR)/$(DROID_OUT)/$$(private_device)/blf/ ]; then \
	cp -r $(SRC_DIR)/$(DROID_OUT)/$$(private_device)/blf $(OUTPUT_DIR)/$$(private_product)/; fi

	$(hide)if [ -d $(OUTPUT_DIR)/$$(private_product)/dtb ]; then rm -fr $(OUTPUT_DIR)/$$(private_product)/dtb; fi &&\
	mkdir -p $(OUTPUT_DIR)/$$(private_product)/dtb
	$(hide)cp -af $(SRC_DIR)/$(DROID_OUT)/$$(private_device)/*.dtb  $(OUTPUT_DIR)/$$(private_product)/dtb/

	$(hide)find  $(SRC_DIR)/$(DROID_OUT)/$$(private_device)/ -iname radio*img |xargs -i cp {} $(OUTPUT_DIR)/$$(private_product)
	$(hide)find  $(SRC_DIR)/$(DROID_OUT)/$$(private_device)/ -iname *gpt* |xargs -i cp {} $(OUTPUT_DIR)/$$(private_product)
	$(log) "  done"

	$(hide)if [ "$(PLATFORM_ANDROID_VARIANT)" = "user" ]; then \
	sed -i "s/ro.secure=1/ro.secure=0/" $(SRC_DIR)/$(DROID_OUT)/$$(private_device)/root/default.prop  && \
	sed -i "s/ro.debuggable=0/ro.debuggable=1/" $(SRC_DIR)/$(DROID_OUT)/$$(private_device)/root/default.prop  && \
	cd $(SRC_DIR)/$(DROID_OUT)/$$(private_device) && \
	$(SRC_DIR)/$(MKBOOTFS) root | $(SRC_DIR)/$(MINIGZIP) > ramdisk-rooted.img && \
	cat ramdisk-rooted.img < /dev/zero | head -c 1048576 > ramdisk-rooted.img.pad && \
	cp -p -r $(SRC_DIR)/$(DROID_OUT)/$$(private_device)/ramdisk-rooted.img.pad $(OUTPUT_DIR)/$$(private_product)/ramdisk-rooted.img && \
	touch $(OUTPUT_DIR)/product_mode_build.txt; fi
	$(hide)cp $(SRC_DIR)/$(DROID_OUT)/$$(private_device)/obm*bin $(OUTPUT_DIR)/$$(private_product)/
	$(hide)cp $(SRC_DIR)/$(DROID_OUT)/$$(private_device)/uImage $(OUTPUT_DIR)/$$(private_product)/
	$(hide)cp $(SRC_DIR)/$(DROID_OUT)/$$(private_device)/boot.img $(OUTPUT_DIR)/$$(private_product)/
	$(hide)cp $(SRC_DIR)/$(DROID_OUT)/$$(private_device)/cache.img $(OUTPUT_DIR)/$$(private_product)/
	$(hide)cp $(SRC_DIR)/$(DROID_OUT)/$$(private_device)/recovery.img $(OUTPUT_DIR)/$$(private_product)/
	$(hide)cp $(SRC_DIR)/$(DROID_OUT)/$$(private_device)/u-boot.bin $(OUTPUT_DIR)/$$(private_product)/
	$(hide)cp $(SRC_DIR)/$(DROID_OUT)/$$(private_device)/vmlinux $(OUTPUT_DIR)/$$(private_product)/
	$(hide)cp $(SRC_DIR)/$(DROID_OUT)/$$(private_device)/System.map $(OUTPUT_DIR)/$$(private_product)/
	$(hide)cp $(SRC_DIR)/$(DROID_OUT)/$$(private_device)/Software_Downloader.zip $(OUTPUT_DIR)/
	$(hide)if [ -e $(SRC_DIR)/$(DROID_OUT)/$$(private_device)/WTM.bin ]; then cp -p -r $(SRC_DIR)/$(DROID_OUT)/$$(private_device)/WTM.bin $(OUTPUT_DIR)/$$(private_product)/; fi
	$(hide)if [ -e $(SRC_DIR)/$(DROID_OUT)/$$(private_device)/HLN2_NonTLoader_eMMC_DDR.bin ]; then cp -p -r $(SRC_DIR)/$(DROID_OUT)/$$(private_device)/HLN2_NonTLoader_eMMC_DDR.bin $(OUTPUT_DIR)/$$(private_product)/; fi
	$(hide)if [ -e $(SRC_DIR)/$(DROID_OUT)/$$(private_device)/Software_Downloader_Helan2.zip ]; then cp -p -r $(SRC_DIR)/$(DROID_OUT)/$$(private_device)/Software_Downloader_Helan2.zip $(OUTPUT_DIR)/; fi
	$(hide)if [ -d $(OUTPUT_DIR)/$$(private_product)/modules ]; then rm -fr $(OUTPUT_DIR)/$$(private_product)/modules; fi &&\
	mkdir -p $(OUTPUT_DIR)/$$(private_product)/modules
	$(hide)cp -af $(SRC_DIR)/$(DROID_OUT)/$$(private_device)/root/lib/modules  $(OUTPUT_DIR)/$$(private_product)/
	$(hide)cp $(BOARD)/release_package_list $(OUTPUT_DIR)/release_package_list

##!!## first time publish: all for two
PUBLISHING_FILES2+=Software_Downloader.zip:./:m:md5
PUBLISHING_FILES2+=Software_Downloader_Helan2.zip:./:o:md5
PUBLISHING_FILES2+=$$(product)/WTM.bin:./$$(product)/flash/:o:md5
PUBLISHING_FILES2+=$$(product)/HLN2_NonTLoader_eMMC_DDR.bin:./$$(product)/flash/:o:md5
PUBLISHING_FILES2+=$$(product)/obm.bin:./$$(product)/flash/:o:md5
PUBLISHING_FILES2+=$$(product)/obm_auto.bin:./$$(product)/flash/:o:md5
PUBLISHING_FILES2+=$$(product)/obm_trusted_tz.bin:./$$(product)/flash/:o:md5
PUBLISHING_FILES2+=$$(product)/obm_trusted_ntz.bin:./$$(product)/flash/:o:md5
PUBLISHING_FILES2+=$$(product)/u-boot.bin:./$$(product)/flash/:o:md5
PUBLISHING_FILES2+=$$(product)/boot.img:./$$(product)/flash/:o:md5
PUBLISHING_FILES2+=$$(product)/cache.img:./$$(product)/flash/:o:md5
PUBLISHING_FILES2+=$$(product)/recovery.img:./$$(product)/flash/:o:md5
PUBLISHING_FILES2+=$$(product)/uImage:./$$(product)/debug/:o:md5
PUBLISHING_FILES2+=$$(product)/vmlinux:./$$(product)/debug/:o:md5
PUBLISHING_FILES2+=$$(product)/System.map:./$$(product)/debug/:o:md5
PUBLISHING_FILES2+=$$(product)/primary_gpt_4g:./$$(product)/flash/:o:md5
PUBLISHING_FILES2+=$$(product)/secondary_gpt_4g:./$$(product)/flash/:o:md5
PUBLISHING_FILES2+=$$(product)/primary_gpt:./$$(product)/flash/:o:md5
PUBLISHING_FILES2+=$$(product)/secondary_gpt:./$$(product)/flash/:o:md5
PUBLISHING_FILES2+=$$(product)/userdata.img:./$$(product)/flash/:m:md5
PUBLISHING_FILES2+=$$(product)/userdata_4g.img:./$$(product)/flash/:o:md5
PUBLISHING_FILES2+=$$(product)/userdata_8g.img:./$$(product)/flash/:o:md5
PUBLISHING_FILES2+=$$(product)/primary_gpt_8g:./$$(product)/flash/:o:md5
PUBLISHING_FILES2+=$$(product)/secondary_gpt_8g:./$$(product)/flash/:o:md5
PUBLISHING_FILES2+=$$(product)/system.img:./$$(product)/flash/:m:md5
PUBLISHING_FILES2+=$$(product)/ramdisk.img:./$$(product)/debug/:m:md5
PUBLISHING_FILES2+=$$(product)/ramdisk-rooted.img:./$$(product)/debug/:o:md5
PUBLISHING_FILES2+=$$(product)/symbols_system.tgz:./$$(product)/debug/:o:md5
PUBLISHING_FILES2+=$$(product)/ramdisk-recovery.img:./$$(product)/debug/:o:md5
PUBLISHING_FILES2+=$$(product)/build.prop:./$$(product)/debug/:o:md5
PUBLISHING_FILES2+=$$(product)/modules.tgz:./$$(product)/debug/:o:md5
PUBLISHING_FILES2+=product_mode_build.txt:./$$(product)/debug/:o

##!!## blf files
PUBLISHING_FILES2+=$$(product)/blf/*:./$$(product)/flash/:o:md5

##!!## dtb files
PUBLISHING_FILES2+=$$(product)/dtb:./$$(product)/debug/:o:md5

##!!## security image
PUBLISHING_FILES2+=$$(product)/tee_tw.bin:./$$(product)/flash/:o:md5
PUBLISHING_FILES2+=$$(product)/teesst.img:./$$(product)/flash/:o:md5
PUBLISHING_FILES2+=$$(product)/wtm_rel_helan3_VirtualOTP.bin:./$$(product)/flash/:o:md5
PUBLISHING_FILES2+=$$(product)/wtm_rel_helan3_RealOTP.bin:./$$(product)/flash/:o:md5
PUBLISHING_FILES2+=$$(product)/wtm_rel_helan4_VirtualOTP.bin:./$$(product)/flash/:o:md5

PUBLISHING_FILES2+=$$(product)/radio.img:./$$(product)/flash/:o:md5

PUBLISHING_FILES2+=$$(product)/nvm-wb.img:./$$(product)/flash/:o:md5
PUBLISHING_FILES2+=$$(product)/nvm-td.img:./$$(product)/flash/:o:md5
PUBLISHING_FILES2+=$$(product)/nvm.img:./$$(product)/flash/:o:md5

PUBLISHING_FILES2+=$$(product)/HL_CP.bin:./$$(product)/flash/:o:md5
PUBLISHING_FILES2+=$$(product)/EM_CP.bin:./$$(product)/flash/:o:md5
PUBLISHING_FILES2+=$$(product)/EM_CP_DIAG.mdb:./$$(product)/debug/:o:md5
PUBLISHING_FILES2+=$$(product)/EM_CP_NVM.mdb:./$$(product)/debug/:o:md5
PUBLISHING_FILES2+=$$(product)/EM_M08_AI_Z1_Flash.bin:./$$(product)/flash/:o:md5
PUBLISHING_FILES2+=$$(product)/HL_M08_AI_Z1_Flash.bin:./$$(product)/flash/:o:md5
PUBLISHING_FILES2+=$$(product)/KL_CP.bin:./$$(product)/flash/:o:md5
PUBLISHING_FILES2+=$$(product)/KL_CP_DIAG.mdb:./$$(product)/debug/:o:md5
PUBLISHING_FILES2+=$$(product)/KL_CP_NVM.mdb:./$$(product)/debug/:o:md5
PUBLISHING_FILES2+=$$(product)/KUNLUN_Z0_M14_AI_Flash.bin:./$$(product)/flash/:o:md5
PUBLISHING_FILES2+=$$(product)/KUNLUN_A0_M15_AI_Flash.bin:./$$(product)/flash/:o:md5

PUBLISHING_FILES2+=$$(product)/KUNLUN_Arbel.bin:./$$(product)/flash/:o:md5
PUBLISHING_FILES2+=$$(product)/KUNLUN_Arbel_DIAG.mdb:./$$(product)/debug/:o:md5
PUBLISHING_FILES2+=$$(product)/KUNLUN_Arbel_NVM.mdb:./$$(product)/debug/:o:md5

PUBLISHING_FILES2+=$$(product)/HL_TD_CP.bin:./$$(product)/flash/:o:md5
PUBLISHING_FILES2+=$$(product)/HL_TD_CP_DIAG.mdb:./$$(product)/debug/:o:md5
PUBLISHING_FILES2+=$$(product)/HL_TD_CP_NVM.mdb:./$$(product)/debug/:o:md5
PUBLISHING_FILES2+=$$(product)/HL_TD_M08_AI_A0_Flash.bin:./$$(product)/flash/:o:md5
PUBLISHING_FILES2+=$$(product)/radio-helan-td.img:./$$(product)/flash/:o:md5
PUBLISHING_FILES2+=$$(product)/HELAN_A0_M16_AI_Flash.bin:./$$(product)/flash/:o:md5
PUBLISHING_FILES2+=$$(product)/HL_WB_CP.bin:./$$(product)/flash/:o:md5
PUBLISHING_FILES2+=$$(product)/HL_WB_CP_DIAG.mdb:./$$(product)/debug/:o:md5
PUBLISHING_FILES2+=$$(product)/HL_WB_CP_NVM.mdb:./$$(product)/debug/:o:md5
PUBLISHING_FILES2+=$$(product)/HLWT_TD_CP.bin:./$$(product)/flash/:o:md5
PUBLISHING_FILES2+=$$(product)/HLWT_TD_CP_DIAG.mdb:./$$(product)/debug/:o:md5
PUBLISHING_FILES2+=$$(product)/HLWT_TD_CP_NVM.mdb:./$$(product)/debug/:o:md5
PUBLISHING_FILES2+=$$(product)/HLWT_TD_M08_AI_A0_Flash.bin:./$$(product)/flash/:o:md5
PUBLISHING_FILES2+=$$(product)/nvm-helan-wb.img:./$$(product)/flash/:o:md5
PUBLISHING_FILES2+=$$(product)/nvm-helan-wt.img:./$$(product)/flash/:o:md5
PUBLISHING_FILES2+=$$(product)/radio-helan-wb.img:./$$(product)/flash/:o:md5
PUBLISHING_FILES2+=$$(product)/radio-helan-wt.img:./$$(product)/flash/:o:md5

PUBLISHING_FILES2+=$$(product)/TABLET_CP.bin:./$$(product)/flash/:o:md5
PUBLISHING_FILES2+=$$(product)/TABLET_MSA.bin:./$$(product)/flash/:o:md5

PUBLISHING_FILES2+=$$(product)/radio-helanlte-ltg.img:./$$(product)/flash/:o:md5
PUBLISHING_FILES2+=$$(product)/HL_DL_M09_Y0_AI_SKL_Flash.bin:./$$(product)/flash/:o:md5
PUBLISHING_FILES2+=$$(product)/HL_LTG_DL.bin:./$$(product)/flash/:o:md5
PUBLISHING_FILES2+=$$(product)/HL_LTG_DIAG.mdb:./$$(product)/debug/:o:md5
PUBLISHING_FILES2+=$$(product)/HL_LTG_NVM.mdb:./$$(product)/debug/:o:md5
PUBLISHING_FILES2+=$$(product)/nvm-helanlte-ltg.img:./$$(product)/flash/:o:md5
PUBLISHING_FILES2+=$$(product)/HL_DL_M09_Y0_AI_SKL_Flash.bin:./$$(product)/flash/:o:md5
PUBLISHING_FILES2+=$$(product)/HL_LTG_DL_DIAG.mdb:./$$(product)/debug/:o:md5
PUBLISHING_FILES2+=$$(product)/HL_LTG_DL_DKB.bin:./$$(product)/flash/:o:md5
PUBLISHING_FILES2+=$$(product)/HL_LTG_DL_NVM.mdb:./$$(product)/debug/:o:md5
PUBLISHING_FILES2+=$$(product)/HL_LWG_DIAG.mdb:./$$(product)/debug/:o:md5
PUBLISHING_FILES2+=$$(product)/HL_LWG_DKB.bin:./$$(product)/flash/:o:md5
PUBLISHING_FILES2+=$$(product)/HL_LWG_M09_B0_SKL_Flash.bin:./$$(product)/flash/:o:md5
PUBLISHING_FILES2+=$$(product)/HL_LWG_NVM.mdb:./$$(product)/debug/:o:md5
PUBLISHING_FILES2+=$$(product)/nvm-helanlte.img:./$$(product)/flash/:o:md5
PUBLISHING_FILES2+=$$(product)/Skylark_LTG.bin:./$$(product)/flash/:o:md5
PUBLISHING_FILES2+=$$(product)/Skylark_LWG.bin:./$$(product)/flash/:o:md5
PUBLISHING_FILES2+=$$(product)/radio-helanlte.img:./$$(product)/flash/:o:md5
PUBLISHING_FILES2+=$$(product)/HL_SS_M09_Y0_AI_SKL_Flash.bin:./$$(product)/flash/:o:md5
PUBLISHING_FILES2+=$$(product)/HL_LTG_SL_DKB_DIAG.mdb:./$$(product)/debug/:o:md5
PUBLISHING_FILES2+=$$(product)/HL_LTG_SL_DKB.bin:./$$(product)/flash/:o:md5
PUBLISHING_FILES2+=$$(product)/HL_LTG_SL_DKB_NVM.mdb:./$$(product)/debug/:o:md5
PUBLISHING_FILES2+=$$(product)/Skylark_LTG_V11.bin:./$$(product)/flash/:o:md5
PUBLISHING_FILES2+=$$(product)/Skylark_LTG_V13.bin:./$$(product)/flash/:o:md5
PUBLISHING_FILES2+=$$(product)/Skylark_LWG_V11.bin:./$$(product)/flash/:o:md5
PUBLISHING_FILES2+=$$(product)/Skylark_LWG_V13.bin:./$$(product)/flash/:o:md5
PUBLISHING_FILES2+=$$(product)/HL_LTG_SL_DKB_MDB.bin:./$$(product)/flash/:o:md5
PUBLISHING_FILES2+=$$(product)/HL_LWG_MDB.bin:./$$(product)/flash/:o:md5
PUBLISHING_FILES2+=$$(product)/HL4_LTG_DKB_DSDS_SHM_TX.bin:./$$(product)/flash/:o:md5
PUBLISHING_FILES2+=$$(product)/NEZHA3_LTG_M10_Z3_ARG_Flash.bin:./$$(product)/flash/:o:md5
PUBLISHING_FILES2+=$$(product)/LTG_ZIP_RF.bin:./$$(product)/flash/:o:md5
PUBLISHING_FILES2+=$$(product)/NZ3_LTG_DKB_40M_DSDS_TX_MDB.bin:./$$(product)/flash/:o:md5
PUBLISHING_FILES2+=$$(product)/HL4_LWG_DKB_DSDS_SHM_TX.bin:./$$(product)/flash/:o:md5
PUBLISHING_FILES2+=$$(product)/NEZHA3_LWG_M10_Z3_ARG_Flash.bin:./$$(product)/flash/:o:md5
PUBLISHING_FILES2+=$$(product)/LWG_ZIP_RF.bin:./$$(product)/flash/:o:md5
PUBLISHING_FILES2+=$$(product)/NZ3_LWG_DKB_40M_DSDS_TX_MDB.bin:./$$(product)/flash/:o:md5
PUBLISHING_FILES2+=$$(product)/Argus_LTG.bin:./$$(product)/debug/:o:md5
PUBLISHING_FILES2+=$$(product)/Argus_LWG.bin:./$$(product)/debug/:o:md5
PUBLISHING_FILES2+=$$(product)/NZ3_LTG_DKB_40M_DSDS_TX_MDB.txt:./$$(product)/debug/:o:md5
PUBLISHING_FILES2+=$$(product)/NZ3_LWG_DKB_40M_DSDS_TX_MDB.txt:./$$(product)/debug/:o:md5

#1936 specific begin
PUBLISHING_FILES2+=$$(product)/HL_SS_M09_Y0_AI_SKL_Flash.bin:./$$(product)/flash/:o:md5
PUBLISHING_FILES2+=$$(product)/HL_LTG_SL_DKB_DSDS.bin:./$$(product)/flash/:o:md5
PUBLISHING_FILES2+=$$(product)/HL_SS_M09_Y0_AI_SKL_Flash.bin:./$$(product)/flash/:o:md5
PUBLISHING_FILES2+=$$(product)/Skylark_LTG_V15.bin:./$$(product)/flash/:o:md5
PUBLISHING_FILES2+=$$(product)/HL_LTG_SL_DKB_DSDS_MDB.bin:./$$(product)/flash/:o:md5
#1936 specific end

PUBLISHING_FILES2+=$$(product)/LTG_ZIP_RF.bin:./$$(product)/flash/:o:md5
PUBLISHING_FILES2+=$$(product)/LWG_ZIP_RF.bin:./$$(product)/flash/:o:md5

PUBLISHING_FILES2+=$$(product)/HL_LWG_DKB_NVM.mdb:./$$(product)/debug/:o:md5
PUBLISHING_FILES2+=$$(product)/HL_LWG_DKB_DIAG.mdb:./$$(product)/debug/:o:md5
PUBLISHING_FILES2+=$$(product)/HL_LTG_SL_DKB_DSDS_NVM.mdb:./$$(product)/debug/:o:md5
PUBLISHING_FILES2+=$$(product)/HL_LTG_SL_DKB_DSDS_DIAG.mdb:./$$(product)/debug/:o:md5

PUBLISHING_FILES2+=$$(product)/ULC_SS_M09_Y0_AI_SKL_Flash.bin:./$$(product)/flash/:o:md5
PUBLISHING_FILES2+=$$(product)/ULC_LWG_M09_B0_DSDS_SKL_Flash.bin:./$$(product)/flash/:o:md5
PUBLISHING_FILES2+=$$(product)/Skylark_LWG_V15.bin:./$$(product)/flash/:o:md5
PUBLISHING_FILES2+=$$(product)/Skylark_LTG_V15.bin:./$$(product)/flash/:o:md5
PUBLISHING_FILES2+=$$(product)/HL_LWG_DKB_MDB.bin:./$$(product)/flash/:o:md5
PUBLISHING_FILES2+=$$(product)/HL_LTG_SL_DKB_DSDS_MDB.bin:./$$(product)/flash/:o:md5
PUBLISHING_FILES2+=$$(product)/HL_LTG_SL_DKB_DSDS.bin:./$$(product)/flash/:o:md5
PUBLISHING_FILES2+=$$(product)/HL_LWG_M09_B0_DSDS_SKL_Flash.bin:./$$(product)/flash/:o:md5
PUBLISHING_FILES2+=$$(product)/SAAR_H_ALL_configuration.bin:./$$(product)/flash/:o:md5

PUBLISHING_FILES2+=$$(product)/WK_CP_2CHIP_SPRW_NVM.mdb:./$$(product)/debug/:o:md5
PUBLISHING_FILES2+=$$(product)/WK_CP_2CHIP_SPRW_DIAG.mdb:./$$(product)/debug/:o:md5
PUBLISHING_FILES2+=$$(product)/Boerne_DIAG.mdb.txt:./$$(product)/debug/:o:md5
PUBLISHING_FILES2+=$$(product)/ReliableData.bin:./$$(product)/flash/:o:md5
ifeq ($(product),pxa1908dkb_def)
PUBLISHING_FILES2+=$$(product)/Arbel_DIGRF3_NVM.mdb:./$$(product)/debug/:o:md5
PUBLISHING_FILES2+=$$(product)/Arbel_DIGRF3.bin:./$$(product)/flash/:o:md5
PUBLISHING_FILES2+=$$(product)/Arbel_DIGRF3_DIAG.mdb:./$$(product)/debug/:o:md5
PUBLISHING_FILES2+=$$(product)/Arbel_DKB_SKWS.bin:./$$(product)/flash/:o:md5
PUBLISHING_FILES2+=$$(product)/Arbel_DKB_SKWS_NVM.mdb:./$$(product)/debug/:o:md5
PUBLISHING_FILES2+=$$(product)/Arbel_DKB_SKWS_DIAG.mdb:./$$(product)/debug/:o:md5
PUBLISHING_FILES2+=$$(product)/TTD_M06_AI_A0_Flash.bin:./$$(product)/flash/:o:md5
PUBLISHING_FILES2+=$$(product)/TTD_M06_AI_A1_Flash.bin:./$$(product)/flash/:o:md5
PUBLISHING_FILES2+=$$(product)/TTD_M06_AI_Y0_Flash.bin:./$$(product)/flash/:o:md5
PUBLISHING_FILES2+=$$(product)/WK_CP_2CHIP_SPRW.bin:./$$(product)/flash/:o:md5
PUBLISHING_FILES2+=$$(product)/WK_M08_AI_Y1_removelo_Y0_Flash.bin:./$$(product)/flash/:o:md5
endif
endef
PUBLISHING_FILES+=release_package_list:o

define define-build-droid-debug-img
tw:=$$(subst :,  , $(1) )
product:=$$(word 1, $$(tw) )
device:=$$(word 2, $$(tw) )
.PHONY: build_droid_debug_img_$$(product)
build_droid_debug_img_$$(product): private_product:=$$(product)
build_droid_debug_img_$$(product): private_device:=$$(device)
build_droid_debug_img_$$(product): build_droid_$$(product)
ifneq ($(filter $(ABS_DROID_BRANCH),aosp pdk5.0 lmr1 lmr1_32),)
	$(log) "[$$(private_product)] disable make debug image to put .ko files to /system/lib/modules"
else
	$(log) "[$$(private_product)] make debug image to put .ko files to /system/lib/modules"
	$(hide)cd $(SRC_DIR) && \
	source ./build/envsetup.sh && \
	chooseproduct $$(private_product) && choosetype $(DROID_TYPE) && choosevariant $(DROID_VARIANT) && \
	cd $(SRC_DIR)/$(DROID_OUT)/$$(private_device) && \
	cp -fr root/ root-bak && \
	find root/ -iname "*.rc"|xargs sed -i -r 's/\/lib\/modules/\/system\/lib\/modules/' && \
	cd root/ && find . | cpio -o -H newc | gzip > ../ramdisk-debug.img && cd ../ &&\
	mkbootimg --ramdisk ramdisk-debug.img --kernel uImage -o boot-debug.img && \
	mkdir -p system/lib/modules/ && \
	cp root/lib/modules/* system/lib/modules/ && \
	rm -fr root/ && mv root-bak root && \
	mv $(SRC_DIR)/$(DROID_OUT)/$$(private_device)/system.img $(SRC_DIR)/$(DROID_OUT)/$$(private_device)/system.img.bak && \
	cd $(SRC_DIR) && \
	make snod && \
	mv $(SRC_DIR)/$(DROID_OUT)/$$(private_device)/system.img $(SRC_DIR)/$(DROID_OUT)/$$(private_device)/system-debug.img && \
	mv $(SRC_DIR)/$(DROID_OUT)/$$(private_device)/system.img.bak $(SRC_DIR)/$(DROID_OUT)/$$(private_device)/system.img

	$(hide)echo "copy debug images"

	mkdir -p $(OUTPUT_DIR)/$$(private_product)/debug_gc_img/
	$(hide)cp -p -r $(SRC_DIR)/$(DROID_OUT)/$$(private_device)/ramdisk-debug.img $(OUTPUT_DIR)/$$(private_product)/debug_gc_img/
	$(hide)cp -p -r $(SRC_DIR)/$(DROID_OUT)/$$(private_device)/boot-debug.img $(OUTPUT_DIR)/$$(private_product)/debug_gc_img/
	$(hide)cp -p -r $(SRC_DIR)/$(DROID_OUT)/$$(private_device)/system-debug.img $(OUTPUT_DIR)/$$(private_product)/debug_gc_img/
endif
	$(log) "  done for make debug images build."

PUBLISHING_FILES2+=$$(product)/debug_gc_img/ramdisk-debug.img:./$$(product)/debug/debug_gc_img/:o:md5
PUBLISHING_FILES2+=$$(product)/debug_gc_img/boot-debug.img:./$$(product)/debug/debug_gc_img/:o:md5
PUBLISHING_FILES2+=$$(product)/debug_gc_img/system-debug.img:./$$(product)/debug/debug_gc_img/:o:md5

endef

define define-build-droid-otapackage
tw:=$$(subst :,  , $(1) )
product:=$$(word 1, $$(tw) )
device:=$$(word 2, $$(tw) )
.PHONY: build_droid_otapackage_$$(product)
build_droid_otapackage_$$(product): private_product:=$$(product)
build_droid_otapackage_$$(product): private_device:=$$(device)
build_droid_otapackage_$$(product): 
ifneq ($(filter $(ABS_DROID_BRANCH),aosp pdk5.0 lmr1 lmr1_32),)
	$$(log) "disalbe otapackage build by generating fake ota files temporally"
	$$(hide)touch $$(OUTPUT_DIR)/$$(private_product)/$$(private_product)-ota-mrvl.zip
	$$(hide)touch $$(OUTPUT_DIR)/$$(private_product)/$$(private_product)-ota-mrvl-recovery.zip
	$$(hide)touch $$(OUTPUT_DIR)/$$(private_product)/$$(private_product)-ota-mrvl-intermediates.zip
else
	$(log) "[$$(private_product)] building android OTA package ..."
	$(hide)cd $(SRC_DIR) && \
	source ./build/envsetup.sh && \
	chooseproduct $$(private_product) && choosetype $(DROID_TYPE) && choosevariant $(DROID_VARIANT) && \
	make mrvlotapackage
	$(hide)echo "  copy OTA package ..."

	$(hide)cp -p -r $(SRC_DIR)/$(DROID_OUT)/$$(private_device)/$$(private_product)-ota-mrvl.zip $(OUTPUT_DIR)/$$(private_product)
	$(hide)cp -p -r $(SRC_DIR)/$(DROID_OUT)/$$(private_device)/$$(private_product)-ota-mrvl-recovery.zip $(OUTPUT_DIR)/$$(private_product)
	$(hide)cp -p -r $(SRC_DIR)/$(DROID_OUT)/$$(private_device)/obj/PACKAGING/target_files_intermediates/$$(private_product)-target_files*.zip $(OUTPUT_DIR)/$$(private_product)/$$(private_product)-ota-mrvl-intermediates.zip
endif
	$(log) "  done for OTA package build."

PUBLISHING_FILES2+=$$(product)/$$(product)-ota-mrvl.zip:./$$(product)/ota/:o:md5
PUBLISHING_FILES2+=$$(product)/$$(product)-ota-mrvl-recovery.zip:./$$(product)/ota/:o:md5
PUBLISHING_FILES2+=$$(product)/$$(product)-ota-mrvl-intermediates.zip:./$$(product)/ota/:o:md5
PUBLISHING_FILES2+=$$(product)/target_files-package.zip:./$$(product)/ota/:o:md5

endef
#define define-build-droid-otapackage
#tw:=$$(subst :,  , $(1) )
#product:=$$(word 1, $$(tw) )
#device:=$$(word 2, $$(tw) )
#.PHONY: build_droid_otapackage_$$(product)
#build_droid_otapackage_$$(product): private_product:=$$(product)
#build_droid_otapackage_$$(product): private_device:=$$(device)
#build_droid_otapackage_$$(product): build_uboot_obm_$$(product)
#	$(log) "[$$(private_product)] no android OTA package build ..."
#endef

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

PUBLISHING_FILES2+=$$(product)/tools.img:./$$(product)/flash/:o:md5
PUBLISHING_FILES2+=$$(product)/tools.tgz:./$$(product)/flash/:o:md5

endef

#This target will remake kernel with more debug options
define define-build-debug-kernel-target
tw:=$$(subst :,  , $(1) )
product:=$$(word 1, $$(tw) )
device:=$$(word 2, $$(tw) )
.PHONY: build_debug_kernel_$$(product) 
build_debug_kernel_$$(product): private_product:=$$(product)
build_debug_kernel_$$(product): private_device:=$$(device)
build_debug_kernel_$$(product): 
ifneq ($(filter $(ABS_DROID_BRANCH),aosp pdk5.0 lmr1 lmr1_32),)
	$(log) "[$$(private_product)] disbale debug uImage ...private_product is"+$$(private_product)+"private_device is "+$$(private_device)
else
	$(log) "[$$(private_product)] building debug uImage ...private_product is"+$$(private_product)+"private_device is "+$$(private_device)
	cd $(SRC_DIR)/$(DROID_OUT)/$$(private_device) && \
    cp -fr root/ root-bak 
	$(hide)cd $(SRC_DIR) && \
	source ./build/envsetup.sh && \
	chooseproduct $$(private_product) && choosetype $(DROID_TYPE) && choosevariant $(DROID_VARIANT) && \
	make build-debug-galcore && \
	cd $(SRC_DIR)/$(DROID_OUT)/$$(private_device) && \
    cd root/ && find . | cpio -o -H newc | gzip > ../ramdisk-debug.img && cd ../ &&\
    mkbootimg --ramdisk ramdisk-debug.img --kernel uImage_debug -o boot-debug.img && \
    rm -fr root/ && mv root-bak root 

	mkdir -p $(OUTPUT_DIR)/$$(private_product)/debug_kernel_img
	$(hide)cp $(SRC_DIR)/$(DROID_OUT)/$$(private_device)/uImage_debug $(OUTPUT_DIR)/$$(private_product)/debug_kernel_img
	$(hide)cp $(SRC_DIR)/$(DROID_OUT)/$$(private_device)/System_debug.map $(OUTPUT_DIR)/$$(private_product)/debug_kernel_img/System_debug.map
	$(hide)cp $(SRC_DIR)/$(DROID_OUT)/$$(private_device)/vmlinux_debug $(OUTPUT_DIR)/$$(private_product)/debug_kernel_img/vmlinux_debug
	$(hide)cp -p -r $(SRC_DIR)/$(DROID_OUT)/$$(private_device)/ramdisk-debug.img $(OUTPUT_DIR)/$$(private_product)/debug_kernel_img/
	$(hide)cp -p -r $(SRC_DIR)/$(DROID_OUT)/$$(private_device)/boot-debug.img $(OUTPUT_DIR)/$$(private_product)/debug_kernel_img/
	tar zcf $(OUTPUT_DIR)/$$(private_product)/debug_kernel_img/modules_debug.tgz -C $(SRC_DIR)/$(DROID_OUT)/$$(private_device)/root/lib modules 
endif
	$(log) "  done for make debug kernel target build."

PUBLISHING_FILES2+=$$(product)/debug_kernel_img/uImage_debug:./$$(product)/debug/debug_kernel_img/:o:md5
PUBLISHING_FILES2+=$$(product)/debug_kernel_img/System_debug.map:./$$(product)/debug/debug_kernel_img/:o:md5
PUBLISHING_FILES2+=$$(product)/debug_kernel_img/vmlinux_debug:./$$(product)/debug/debug_kernel_img/:o:md5
PUBLISHING_FILES2+=$$(product)/debug_kernel_img/ramdisk-debug.img:./$$(product)/debug/debug_kernel_img/:o:md5
PUBLISHING_FILES2+=$$(product)/debug_kernel_img/boot-debug.img:./$$(product)/debug/debug_kernel_img/:o:md5
PUBLISHING_FILES2+=$$(product)/debug_kernel_img/modules_debug.tgz:./$$(product)/debug/debug_kernel_img/:o:md5

endef


$(foreach bv,$(ABS_BUILD_DEVICES), $(eval $(call define-build-droid-kernel-target,$(bv)) )\
				$(eval $(call define-build-kernel-target,$(bv)) ) \
				$(eval $(call define-build-droid-target,$(bv)) ) \
				$(eval $(call define-clean-droid-kernel-target,$(bv)) ) \
				$(eval $(call define-build-droid-otapackage,$(bv)) ) \
				$(eval $(call define-build-debug-kernel-target,$(bv)) ) \
				$(eval $(call define-build-droid-debug-img,$(bv)) ) \
)
