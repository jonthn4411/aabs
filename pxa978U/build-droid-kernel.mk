#check if the required variables have been set.
$(call check-variables, ABS_SOC ABS_DROID_BRANCH ABS_DROID_VARIANT)

MY_SCRIPT_DIR:=$(TOP_DIR)/$(ABS_SOC)

DROID_TYPE:=release
DROID_VARIANT:=$(ABS_DROID_VARIANT)

KERNELSRC_TOPDIR:=kernel



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
build_droid_kernel_$$(product): build_kernel_$$(product) build_droid_$$(product) build_telephony_$$(product) build_droid_update_pkgs_$$(product)
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
PUBLISHING_FILES+=$$(product)/zImage:m:md5
PUBLISHING_FILES+=$$(product)/zImage-recovery:m:md5
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
	$(hide)cp $(SRC_DIR)/$(KERNELSRC_TOPDIR)/out/zImage $(OUTPUT_DIR)/$$(private_product)/
	$(hide)cp $(SRC_DIR)/$(KERNELSRC_TOPDIR)/out/zImage-recovery $(OUTPUT_DIR)/$$(private_product)/
	$(hide)cp $(SRC_DIR)/$(KERNELSRC_TOPDIR)/kernel/vmlinux $(OUTPUT_DIR)/$$(private_product)/
	$(hide)cp $(SRC_DIR)/$(KERNELSRC_TOPDIR)/kernel/System.map $(OUTPUT_DIR)/$$(private_product)/
	$(hide)if [ -d $(OUTPUT_DIR)/$$(private_product)/modules ]; then rm -fr $(OUTPUT_DIR)/$$(private_product)/modules; fi &&\
	mkdir -p $(OUTPUT_DIR)/$$(private_product)/modules
	$(hide)cp $(SRC_DIR)/$(KERNELSRC_TOPDIR)/out/modules/* $(OUTPUT_DIR)/$$(private_product)/modules
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
	make -j$(MAKE_JOBS)

	$(hide)if [ -d $(OUTPUT_DIR)/$$(private_product)/root ]; then rm -fr $(OUTPUT_DIR)/$$(private_product)/root; fi
	$(hide)echo "  copy root directory ..." 
	$(hide)mkdir -p $(OUTPUT_DIR)/$$(private_product)
	$(hide)cp -p -r $(SRC_DIR)/out/target/product/$$(private_device)/root $(OUTPUT_DIR)/$$(private_product)
	$(hide)cp -p -r $(SRC_DIR)/out/target/product/$$(private_device)/ramdisk.img $(OUTPUT_DIR)/$$(private_product)
	$(hide)cp -p -r $(SRC_DIR)/out/target/product/$$(private_device)/ramdisk-recovery.img $(OUTPUT_DIR)/$$(private_product)
	$(hide)cp -p -r $(SRC_DIR)/out/target/product/$$(private_device)/userdata.img $(OUTPUT_DIR)/$$(private_product)
	$(hide)cp -p -r $(SRC_DIR)/out/target/product/$$(private_device)/system.img $(OUTPUT_DIR)/$$(private_product)
	$(log) "  done"
##!!## first time publish: all for two
PUBLISHING_FILES+=$$(product)/userdata.img:m:md5
PUBLISHING_FILES+=$$(product)/system.img:m:md5
PUBLISHING_FILES+=$$(product)/ramdisk.img:m:md5
PUBLISHING_FILES+=$$(product)/symbols_system.tgz:o:md5
PUBLISHING_FILES+=$$(product)/ramdisk-recovery.img:m:md5
PUBLISHING_FILES+=$$(product)/build.prop:o:md5
endef


define define-build-telephony-target
tw:=$$(subst :,  , $(1) )
product:=$$(word 1, $$(tw) )
device:=$$(word 2, $$(tw) )
.PHONY: build_telephony_$$(product)
ifeq ($(ABS_DROID_BRANCH),ics)
PUBLISHING_FILES+=$$(product)/Arbel.bin:m:md5
PUBLISHING_FILES+=$$(product)/Arbel_DIAG.mdb:m:md5
PUBLISHING_FILES+=$$(product)/Arbel_NVM.mdb:m:md5
PUBLISHING_FILES+=$$(product)/NEVO_C0_Flash.bin:m:md5
PUBLISHING_FILES+=$$(product)/nvm_ext2.img:m:md5
PUBLISHING_FILES+=$$(product)/plugin_LYRA5V03_BANDS128.bin:m:md5
PUBLISHING_FILES+=$$(product)/pxafs_lyra_ext2.img:m:md5
PUBLISHING_FILES+=$$(product)/pxafs_symbols.tgz:m:md5
PUBLISHING_FILES+=$$(product)/Boerne_DIAG_MTIL.mdb.txt:m:md5
endif

build_telephony_$$(product): private_product:=$$(product)
build_telephony_$$(product): private_device:=$$(device)
build_telephony_$$(product): build_droid_$$(product)
	$(log) "[$$(private_product)]starting to build telephony..."
	$(hide)cd $(SRC_DIR) && \
	source ./build/envsetup.sh && \
	chooseproduct $$(private_product) && choosetype $(DROID_TYPE) && choosevariant $(DROID_VARIANT) && \
	cd $(SRC_DIR)/$(KERNELSRC_TOPDIR) && \
	make telephony

	$$(hide)mkdir -p $(OUTPUT_DIR)/$$(private_product)
	$$(log) "    copy telephony files ..."
	$$(hide)if [ -d $(SRC_DIR)/$(KERNELSRC_TOPDIR)/out/telephony ]; then cp -a $(SRC_DIR)/$(KERNELSRC_TOPDIR)/out/telephony/* /$(OUTPUT_DIR)/$$(private_product); fi
	$(log) "  done."
endef

define define-build-droid-update-pkgs
tw:=$$(subst :,  , $(1) )
product:=$$(word 1, $$(tw) )
device:=$$(word 2, $$(tw) )
.PHONY: build_droid_update_pkgs_$$(product)
build_droid_update_pkgs_$$(product): private_product:=$$(product)
build_droid_update_pkgs_$$(product): private_device:=$$(device)
build_droid_update_pkgs_$$(product): build_uboot_obm_$$(product)
	$$(log) "[$$(private_product)]generating update packages..."
	$(hide)cd $(SRC_DIR) && \
	source ./build/envsetup.sh && \
	chooseproduct $$(private_product) && choosetype $(DROID_TYPE) && choosevariant $(DROID_VARIANT) && \
	make mrvlotapackage
	echo "    copy update packages..." && \
		mkdir -p $$(OUTPUT_DIR)/$(1) && \
		cp -p $(SRC_DIR)/out/target/product/$$(private_device)/pxa978saarc_def-ota-mrvl.zip $(OUTPUT_DIR)/$$(private_product)/pxa978saarc_def-ota-mrvl.zip
	$(log) "  done"

PUBLISHING_FILES+=$$(product)/pxa978saarc_def-ota-mrvl.zip:m:md5
endef




$(foreach bv,$(ABS_BUILD_DEVICES), $(eval $(call define-build-droid-kernel-target,$(bv)) )\
				$(eval $(call define-build-kernel-target,$(bv)) ) \
				$(eval $(call define-build-droid-target,$(bv)) ) \
				$(eval $(call define-build-telephony-target,$(bv)) ) \
				$(eval $(call define-clean-droid-kernel-target,$(bv)) ) \
				$(eval $(call define-build-droid-update-pkgs,$(bv)) ) \
)
