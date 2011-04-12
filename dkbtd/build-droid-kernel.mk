#check if the required variables have been set.
#$(call check-variables,BUILD_VARIANTS)

DEMO_MEDIA_DIR:=/autobuild/demomedia
MY_SCRIPT_DIR:=$(TOP_DIR)/dkbtd

ifeq ($(ANDROID_VERSION),eclair)
       DROID_PRODUCT:=dkbtd
       KERNEL_IMAGE:=zImage
else
       DROID_PRODUCT:=dkb
       KERNEL_IMAGE:=uImage
endif
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

#we need first build the android, so we get the root dir 
# and then we build the kernel images with the root dir and get the package of corresponding modules
# and then we use those module package to build corresponding android package.

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
	$$(hide)if [ -d $$(OUTPUT_DIR)/$(1)/root ]; then rm -fr $(OUTPUT_DIR)/$(1)/root; fi
	$$(hide)echo "  copy root directory ..." 
	$$(hide)mkdir -p $$(OUTPUT_DIR)/$(1)
	$$(hide)cp -p -r $$(SRC_DIR)/out/target/product/$$(DROID_PRODUCT)/root $$(OUTPUT_DIR)/$(1) 
	$$(hide)cp -p -r $$(SRC_DIR)/out/target/product/$$(DROID_PRODUCT)/ramdisk.img $$(OUTPUT_DIR)/$(1)
	$$(hide)cp -p -r $$(SRC_DIR)/out/target/product/$$(DROID_PRODUCT)/userdata.img $$(OUTPUT_DIR)/$(1)
	$$(hide)cp -p -r $$(SRC_DIR)/out/target/product/$$(DROID_PRODUCT)/userdata_ext3.img $$(OUTPUT_DIR)/$(1)
	$$(hide)cp -p -r $$(SRC_DIR)/out/target/product/$$(DROID_PRODUCT)/system.img $$(OUTPUT_DIR)/$(1)
	$$(hide)cp -p -r $$(SRC_DIR)/out/target/product/$$(DROID_PRODUCT)/system_ext3.img $$(OUTPUT_DIR)/$(1)
	$$(hide)cp -p -r $$(SRC_DIR)/out/target/product/$$(DROID_PRODUCT)/ramdisk-recovery.img $$(OUTPUT_DIR)/$(1)
	$(log) "  done"

PUBLISHING_FILES_$(1)+=$(1)/userdata.img:m:md5
PUBLISHING_FILES_$(1)+=$(1)/userdata_ext3.img:m:md5
PUBLISHING_FILES_$(1)+=$(1)/system.img:m:md5
PUBLISHING_FILES_$(1)+=$(1)/system_ext3.img:m:md5
PUBLISHING_FILES_$(1)+=$(1)/ramdisk.img:m:md5
PUBLISHING_FILES_$(1)+=$(1)/ramdisk-recovery.img:m:md5
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
.PHONY: build_droid_$(2)_$(1) 
build_droid_$(2)_$(1): rebuild_droid_$(2)_$(1) package_droid_slc_$(2)_$(1) package_droid_mmc_$(2)_$(1)
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
define package-droid-slc-config
.PHONY:package_droid_slc_$(1)_$(2)
package_droid_slc_$(1)_$(2):
	$$(log) "[$(2)]package file system for booting android from SLC for $(1)..."
	$$(log) "  updating the modules..."
	$$(hide)if [ -d $$(OUTPUT_DIR)/$(2)/modules ]; then rm -fr $$(OUTPUT_DIR)/$(2)/modules; fi
	$$(hide)mkdir -p $$(OUTPUT_DIR)/$(2)
	$$(hide)cd $$(OUTPUT_DIR)/$(2) && tar xzf modules_android_slc.tgz
	$$(hide)export ANDROID_PREBUILT_MODULES=$$(OUTPUT_DIR)/$(2)/modules && \
	cd $$(SRC_DIR) && \
	source ./build/envsetup.sh && \
	chooseproduct $$(DROID_PRODUCT) && choosetype $$(DROID_TYPE) && choosevariant $$(DROID_VARIANT) && \
	make -j$$(MAKE_JOBS) && \
	echo "    copy  image files..." && \
	cp -p $(SRC_DIR)/out/target/product/$$(DROID_PRODUCT)/system.img $$(OUTPUT_DIR)/$(2)/system.img && \
	cp -p $(SRC_DIR)/out/target/product/$$(DROID_PRODUCT)/userdata.img $$(OUTPUT_DIR)/$(2)/userdata.img &&\
	cp -p $(SRC_DIR)/out/target/product/$$(DROID_PRODUCT)/system_etx3.img $$(OUTPUT_DIR)/$(2)/ && \
	cp -p $(SRC_DIR)/out/target/product/$$(DROID_PRODUCT)/userdata_ext3.img $$(OUTPUT_DIR)/$(2)/
	$$(hide)cp -a $$(SRC_DIR)/out/target/product/$$(DROID_PRODUCT)/symbols/system/lib $$(OUTPUT_DIR)/$(2)/
	$$(hide)cd $$(OUTPUT_DIR)/$(2) && tar czf symbols_lib.tgz lib && rm lib -rf
	$$(log) "  done for package_droid_slc_$(1)$(2)."

#PUBLISHING_FILES_$(2)+=$(2)/system_ubi_$(1).img:m:md5 
#PUBLISHING_FILES_$(2)+=$(2)/userdata_ubi_$(1).img:m:md5 
endef

#$1:internal or external
#$2:build variant
define package-droid-mmc-config
.PHONY: package_droid_mmc_$(1)_$(2)
package_droid_mmc_$(1)_$(2):
	$$(log) "[$(2)]package root file system for booting android from SD card or NFS for $(1)."
	$$(hide)if [ -d $$(OUTPUT_DIR)/$(2)/root_nfs ]; then rm -fr $$(OUTPUT_DIR)/$(2)/root_nfs; fi
	$$(hide)cp -r -p $$(OUTPUT_DIR)/$(2)/root $$(OUTPUT_DIR)/$(2)/root_nfs && \
	cp -p -r $$(SRC_DIR)/out/target/product/$$(DROID_PRODUCT)/system $$(OUTPUT_DIR)/$(2)/root_nfs && \
	cp -p -r $$(SRC_DIR)/out/target/product/$$(DROID_PRODUCT)/data $$(OUTPUT_DIR)/$(2)/root_nfs
	$$(hide)cp -rfp $$(SRC_DIR)/vendor/marvell/generic/ttc_telephony/drivers/output/marvell $$(OUTPUT_DIR)/$(2)/root_nfs
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

#$1:build variant
define define-cp-android-root-dir-slc
cp_android_root_dir_slc_$(1):
	$$(log) "[$(1)]copying root directory from $$(OUTPUT_DIR) ..."
	$$(hide)if [ -d "$$(SRC_DIR)/$$(KERNELSRC_TOPDIR)/kernel/root" ]; then rm -fr $$(SRC_DIR)/$$(KERNELSRC_TOPDIR)/kernel/root; fi
	$$(hide)cp -p -r $$(OUTPUT_DIR)/$(1)/root $$(SRC_DIR)/$$(KERNELSRC_TOPDIR)/kernel/ 
	$$(hide)cd $$(SRC_DIR)/$$(KERNELSRC_TOPDIR)/kernel/root && $$(MY_SCRIPT_DIR)/update_root_for_slc.sh 
	$$(hide)mkdir -p $$(OUTPUT_DIR)/$(1)
	$$(hide)cd $$(SRC_DIR)/$$(KERNELSRC_TOPDIR)/kernel && tar czf $$(OUTPUT_DIR)/$(1)/root_android_slc.tgz root/ 
endef

#
#<os>:<storage>:<kernel_cfg>:<root>
# os: the operating system
# storage: the OS will startup from which storage
# kernel_cfg:kernel config file used to build the kernel
# root: optional. If specified, indicating that the kernel image has a root RAM file system.
#example: android:slc:pxa168_android_slc_defconfig:root
# kernel_configs:=
#
kernel_configs:=android:mmc:pxa910_defconfig
kernel_configs+=android:slc:pxa910_defconfig

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
#PUBLISHING_FILES_$(2):=$(PUBLISHING_FILES_$(2)) $(2)/$(KERNEL_IMAGE).$$(os).$$(storage):m:md5
PUBLISHING_FILES_$(2)+=$(2)/$(KERNEL_IMAGE).$$(os).$$(storage):m:md5
PUBLISHING_FILES_$(2)+=$(2)/$(KERNEL_IMAGE).$$(os).$$(storage)_pxa921:m:md5
PUBLISHING_FILES_$(2)+=$(2)/modules_$$(os)_$$(storage).tgz:m:md5

PUBLISHING_FILES_$(2)+=$(2)/pxafs.img:m:md5
PUBLISHING_FILES_$(2)+=$(2)/pxafs_ext3.img:m:md5
PUBLISHING_FILES_$(2)+=$(2)/Boerne_DIAG.mdb.txt:m:md5
PUBLISHING_FILES_$(2)+=$(2)/vmlinux:m:md5
PUBLISHING_FILES_$(2)+=$(2)/vmlinux_pxa921:m:md5
PUBLISHING_FILES_$(2)+=$(2)/System.map:m:md5
PUBLISHING_FILES_$(2)+=$(2)/System.map_pxa921:m:md5

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
	$$(hide)cp $$(SRC_DIR)/$$(KERNELSRC_TOPDIR)/out/$(KERNEL_IMAGE) $$(OUTPUT_DIR)/$(2)/$(KERNEL_IMAGE).$$(private_os).$$(private_storage) 
	$$(hide)cp $$(SRC_DIR)/$$(KERNELSRC_TOPDIR)/out/$(KERNEL_IMAGE)_pxa921 $$(OUTPUT_DIR)/$(2)/$(KERNEL_IMAGE).$$(private_os).$$(private_storage)_pxa921
	$$(hide)cp $$(SRC_DIR)/$$(KERNELSRC_TOPDIR)/out/System.map* $$(OUTPUT_DIR)/$(2)/
	$$(hide)cp $$(SRC_DIR)/$$(KERNELSRC_TOPDIR)/out/vmlinux* $$(OUTPUT_DIR)/$(2)/
	$$(hide)if [ -d $$(OUTPUT_DIR)/$(2)/modules ]; then rm -fr $$(OUTPUT_DIR)/$(2)/modules; fi &&\
	mkdir -p $$(OUTPUT_DIR)/$(2)/modules
	$$(hide)cp $$(SRC_DIR)/$$(KERNELSRC_TOPDIR)/out/modules/* $$(OUTPUT_DIR)/$(2)/modules
	$$(hide)cd $$(OUTPUT_DIR)/$(2) && tar czf modules_$$(private_os)_$$(private_storage).tgz modules/ 
	$$(hide)cp $$(SRC_DIR)/$$(KERNELSRC_TOPDIR)/out/telephony/* /$$(OUTPUT_DIR)/$(2)
	$(log) "  done."

.PHONY: build_kernel_$$(os)_$$(storage)_$(2)
build_kernel_$(2): build_kernel_$$(os)_$$(storage)_$(2)
endef

$(foreach bv,$(BUILD_VARIANTS), $(eval $(call define-build-droid-kernel,$(bv)) )\
								$(eval $(call define-build-droid-root,$(bv)) ) \
								$(eval $(call define-build-droid-pkgs,$(bv)) ) \
								$(eval $(call define-build-droid-config,$(bv),internal) ) \
								$(eval $(call define-build-droid-config,$(bv),external) ) \
								$(eval $(call define-cp-android-root-dir-slc,$(bv)) )\
								$(eval $(call rebuild-droid-config,internal,$(bv)) )\
								$(eval $(call rebuild-droid-config,external,$(bv)) )\
								$(eval $(call package-droid-slc-config,internal,$(bv)) )\
								$(eval $(call package-droid-slc-config,external,$(bv)) )\
								$(eval $(call package-droid-mmc-config,internal,$(bv)) )\
								$(eval $(call package-droid-mmc-config,external,$(bv)) ) \
								$(foreach kc, $(kernel_configs),$(eval $(call define-kernel-target,$(kc),$(bv)) ) )\
)

