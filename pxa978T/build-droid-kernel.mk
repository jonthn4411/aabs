#check if the required variables have been set.
$(call check-variables, ABS_SOC ABS_DROID_BRANCH ABS_DROID_VARIANT)

MY_SCRIPT_DIR:=$(TOP_DIR)/$(ABS_SOC)

DROID_PRODUCT:=978dkb_def
DROID_TYPE:=release
DROID_VARIANT:=$(ABS_DROID_VARIANT)

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

#we need first build the android, so we get the root dir 
# and then we build the kernel images with the root dir and get the package of corresponding modules
# and then we use those module package to build corresponding android package.

.PHONY:build_droid_kernel
build_droid_kernel: build_kernel build_droid build_uboot_obm

##!!## build rootfs for android, make -j4 android, copy root, copy ramdisk/userdata/system.img to outdir XXX
#$1:build variant
.PHONY: build_droid_root 
build_droid_root: output_dir
	$(log) "building android source code ..."
	$(hide)cd $(SRC_DIR) && \
	source ./build/envsetup.sh && \
	chooseproduct $(DROID_PRODUCT) && choosetype $(DROID_TYPE) && choosevariant $(DROID_VARIANT) && \
	ANDROID_PREBUILT_MODULES=no_kernel_modules make -j$(MAKE_JOBS)

	$(hide)if [ -d $(OUTPUT_DIR)/$(1)/root ]; then rm -fr $(OUTPUT_DIR)/$(1)/root; fi
	$(hide)echo "  copy root directory ..." 
	$(hide)mkdir -p $(OUTPUT_DIR)/$(1)
	$(hide)cp -p -r $(SRC_DIR)/out/target/product/$(DROID_PRODUCT)/root $(OUTPUT_DIR)/$(1) 
	$(hide)cp -p -r $(SRC_DIR)/out/target/product/$(DROID_PRODUCT)/ramdisk-recovery.img $(OUTPUT_DIR)/$(1)
	$(hide)cp -p -r $(SRC_DIR)/out/target/product/$(DROID_PRODUCT)/userdata.img $(OUTPUT_DIR)/$(1)
	$(hide)cp -p -r $(SRC_DIR)/out/target/product/$(DROID_PRODUCT)/system.img $(OUTPUT_DIR)/$(1)
	$(log) "  done"
##!!## first time publish: all for two
PUBLISHING_FILES+=$(DROID_PRODUCT)/userdata.img:m:md5
PUBLISHING_FILES+=$(DROID_PRODUCT)/system.img:m:md5
PUBLISHING_FILES+=$(DROID_PRODUCT)/ramdisk.img:m:md5
PUBLISHING_FILES+=$(DROID_PRODUCT)/symbols_system.tgz:o:md5
PUBLISHING_FILES+=$(DROID_PRODUCT)/ramdisk-recovery.img:m:md5
PUBLISHING_FILES+=$(DROID_PRODUCT)/build.prop:o:md5

.PHONY:build_droid_pkgs
build_droid_update_pkgs: output_dir
	$$(log) "generating update packages..."
	$$(hide)cd $$(SRC_DIR) && \
	source ./build/envsetup.sh && \
	chooseproduct $$(DROID_PRODUCT) && choosetype $$(DROID_TYPE) && choosevariant $$(DROID_VARIANT) && \
	make mrvlotapackage
	echo "    copy update packages..." && \
		mkdir -p $$(OUTPUT_DIR)/$(DROID_PRODUCT) && \
		cp -p $(SRC_DIR)/out/target/product/$$(DROID_PRODUCT)/nevo-ota-mrvl.zip $$(OUTPUT_DIR)/$(1)/nevo-ota-mrvl.zip
	$(log) "  done"

build_droid_pkgs: build_droid_update_pkgs_$(1)

PUBLISHING_FILES+=$(DROID_PRODUCT)/nevo-ota-mrvl.zip:m:md5


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
#PUBLISHING_FILES_$(2):=$(PUBLISHING_FILES_$(2)) $(2)/zImage.$$(os).$$(storage):m:md5
PUBLISHING_FILES_$(2)+=$(2)/zImage.$$(os).$$(storage):m:md5
PUBLISHING_FILES_$(2)+=$(2)/vmlinux:o:md5
PUBLISHING_FILES_$(2)+=$(2)/System.map:o:md5
#PUBLISHING_FILES_$(2)+=$(2)/modules_$$(os)_$$(storage).tgz:m:md5
PUBLISHING_FILES_$(2)+=$(2)/pxafs_ext4.img:m:md5
PUBLISHING_FILES_$(2)+=$(2)/pxa_symbols.tgz:o:md5
PUBLISHING_FILES_$(2)+=$(2)/Boerne_DIAG.mdb.txt:m:md5
PUBLISHING_FILES_$(2)+=$(2)/ReliableData.bin:m:md5
ifeq ($(ABS_DROID_BRANCH),ics)
PUBLISHING_FILES_$(2)+=$(2)/Arbel_DIGRF3.bin:m:md5
PUBLISHING_FILES_$(2)+=$(2)/NV_M06_AI_C0_Flash.bin:m:md5
PUBLISHING_FILES_$(2)+=$(2)/NV_M06_AI_C0_L2_I_RAM_SECOND.bin:m:md5
PUBLISHING_FILES_$(2)+=$(2)/Arbel_DIGRF3_NVM.mdb:m:md5
PUBLISHING_FILES_$(2)+=$(2)/Arbel_DIGRF3_DIAG.mdb:m:md5
else
PUBLISHING_FILES_$(2)+=$(2)/Arbel_DKB_SKWS.bin:m:md5
PUBLISHING_FILES_$(2)+=$(2)/TTD_M06_AI_A0_Flash.bin:m:md5
PUBLISHING_FILES_$(2)+=$(2)/TTD_M06_AI_A1_Flash.bin:m:md5
PUBLISHING_FILES_$(2)+=$(2)/TTD_M06_AI_Y0_Flash.bin:m:md5
PUBLISHING_FILES_$(2)+=$(2)/Arbel_DKB_SKWS_NVM.mdb:m:md5
PUBLISHING_FILES_$(2)+=$(2)/Arbel_DKB_SKWS_DIAG.mdb:m:md5
endif

build_kernel_$$(os)_$$(storage)_$(2): private_os:=$$(os)
build_kernel_$$(os)_$$(storage)_$(2): private_storage:=$$(storage)
build_kernel_$$(os)_$$(storage)_$(2): private_root:=$$(root)
build_kernel_$$(os)_$$(storage)_$(2): private_kernel_cfg:=$$(kernel_cfg)
build_kernel_$$(os)_$$(storage)_$(2): private_root:=$$(root)
build_kernel_$$(os)_$$(storage)_$(2): output_dir $$(if $$(findstring root,$$(root)), cp_$$(os)_root_dir_$$(storage)_$(2) ) 
	$$(log) "[$(2)]starting to build kernel for booting $$(private_os) from $$(private_storage) ..."
	$$(log) "    kernel_config: $$(private_kernel_cfg): ..."
	$$(hide)cd $$(SRC_DIR)/$$(KERNELSRC_TOPDIR) && \
	KERNEL_CONFIG=$$(private_kernel_cfg) make all 

	$$(hide)mkdir -p $$(OUTPUT_DIR)/$(2)
	$$(log) "    copy kernel and module files ..."
	$$(hide)cp $$(SRC_DIR)/$$(KERNELSRC_TOPDIR)/out/zImage $$(OUTPUT_DIR)/$(2)/zImage.$$(private_os).$$(private_storage) 
	$$(hide)cp $$(SRC_DIR)/$$(KERNELSRC_TOPDIR)/kernel/vmlinux $$(OUTPUT_DIR)/$(2)
	$$(hide)cp $$(SRC_DIR)/$$(KERNELSRC_TOPDIR)/kernel/System.map $$(OUTPUT_DIR)/$(2)
	$$(hide)if [ -d $$(OUTPUT_DIR)/$(2)/modules ]; then rm -fr $$(OUTPUT_DIR)/$(2)/modules; fi &&\
	mkdir -p $$(OUTPUT_DIR)/$(2)/modules
	$$(hide)cp $$(SRC_DIR)/$$(KERNELSRC_TOPDIR)/out/modules/* $$(OUTPUT_DIR)/$(2)/modules
	$$(hide)cd $$(OUTPUT_DIR)/$(2) && tar czf modules_$$(private_os)_$$(private_storage).tgz modules/ 
	$$(hide)if [ -d $$(SRC_DIR)/$$(KERNELSRC_TOPDIR)/out/telephony ]; then cp -a $$(SRC_DIR)/$$(KERNELSRC_TOPDIR)/out/telephony/* /$$(OUTPUT_DIR)/$(2); fi
	$(log) "  done."

.PHONY: build_kernel_$$(os)_$$(storage)_$(2)
build_kernel_$(2): build_kernel_$$(os)_$$(storage)_$(2)
endef


