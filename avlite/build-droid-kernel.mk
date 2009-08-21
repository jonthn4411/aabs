#check if the required variables have been set.
#$(call check-variables,BUILD_VARIANTS)

DEMO_MEDIA_DIR:=/autobuild/demomedia
MY_SCRIPT_DIR:=$(TOP_DIR)/avlite

DROID_PRODUCT:=avlite
DROID_TYPE:=release
DROID_VARIANT:=eng

KERNEL_SRC_DIR:=kernel

#
# The source directory of the GC300 driver, it should be relative to SRC_DIR.
#GC300_SRC_DIR:=
GC300_SRC_DIR:=gc300_driver

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
	$(hide)cd $(SRC_DIR)/$(KERNEL_SRC_DIR) && make clean
	$(hide)cd $(SRC_DIR)/$(GC300_SRC_DIR) && make avlite-clean
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
	ANDROID_KERNEL_CONFIG=no_kernel_modules make 
	$$(hide)if [ -d $$(OUTPUT_DIR)/$(1)/root ]; then rm -fr $(OUTPUT_DIR)/$(1)/root; fi
	$$(hide)echo "  copy root directory ..." 
	$$(hide)mkdir -p $$(OUTPUT_DIR)/$(1)
	$$(hide)cp -p -r $$(SRC_DIR)/out/target/product/$$(DROID_PRODUCT)/root $$(OUTPUT_DIR)/$(1) 
	$(log) "  done"

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
build_droid_$(2)_$(1): rebuild_droid_$(2)_$(1) package_droid_mlc_$(2)_$(1) package_droid_mmc_$(2)_$(1)
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
	ANDROID_KERNEL_CONFIG=no_kernel_modules make
	$$(log) "    packaging helix libraries and flash library..."
	$$(hide)if [ "$(1)" == "internal" ]; then \
	cd $$(SRC_DIR)/out/target/product/$$(DROID_PRODUCT)/system/lib &&\
	mkdir -p helix &&\
	tar czf $$(OUTPUT_DIR)/$(2)/helix.tgz helix/ && \
	tar czf $$(OUTPUT_DIR)/$(2)/flash.tgz netscape/libflashplayer.so; \
	fi
	$$(log) "  done for rebuild_droid_$(1)_$(2)"

ifeq ($(1),internal)
PUBLISHING_FILES_$(2)+=$(2)/helix.tgz:m:md5
PUBLISHING_FILES_$(2)+=$(2)/flash.tgz:m:md5
endif
endef

#$1:internal or external
#$2:build variant
define package-droid-mlc-config
.PHONY:package_droid_mlc_$(1)_$(2)
package_droid_mlc_$(1)_$(2):
	$$(log) "[$(2)]package file system for booting android from MLC for $(1)..."
	$$(log) "  updating the modules..."
	$$(hide)if [ -d $$(OUTPUT_DIR)/$(2)/modules ]; then rm -fr $$(OUTPUT_DIR)/$(2)/modules; fi
	$$(hide)mkdir -p $$(OUTPUT_DIR)/$(2)
	$$(hide)cd $$(OUTPUT_DIR)/$(2) && tar xzf modules_android_mlc.tgz
	$$(hide)export ANDROID_PREBUILT_MODULES=$$(OUTPUT_DIR)/$(2)/modules && \
	cd $$(SRC_DIR) && \
	source ./build/envsetup.sh && \
	chooseproduct $$(DROID_PRODUCT) && choosetype $$(DROID_TYPE) && choosevariant $$(DROID_VARIANT) && \
	make && \
	echo "    copy UBI image files..." && \
	cp -p $(SRC_DIR)/out/target/product/$$(DROID_PRODUCT)/system_ubi.img $$(OUTPUT_DIR)/$(2)/system_ubi_$(1).img && \
	cp -p $(SRC_DIR)/out/target/product/$$(DROID_PRODUCT)/userdata_ubi.img $$(OUTPUT_DIR)/$(2)/userdata_ubi_$(1).img 
	$$(log) "  done for package_droid_mlc_$(1)$(2)."

PUBLISHING_FILES_$(2)+=$(2)/system_ubi_$(1).img:m:md5 
PUBLISHING_FILES_$(2)+=$(2)/userdata_ubi_$(1).img:m:md5 
endef

#$1:internal or external
#$2:build variant
define package-droid-mmc-config
.PHONY: package_droid_mmc_$(1)_$(2)
package_droid_mmc_$(1)_$(2):
	$$(log) "[$(2)]package root file system for booting android from SD card or NFS for $(1)."
	$$(hide)if [ -d $$(OUTPUT_DIR)/$(2)/root_nfs ]; then rm -fr $$(OUTPUT_DIR)/$(2)/root_nfs; fi
	$$(hide)cp -r -p $$(OUTPUT_DIR)/$(2)/root $$(OUTPUT_DIR)/$(2)/root_nfs && \
	cp -p -r $$(SRC_DIR)/out/target/product/$$(DROID_PRODUCT)/system $$(OUTPUT_DIR)/$(2)/root_nfs
	$$(log) "  updating the modules..."
	$$(hide)if [ -d $$(OUTPUT_DIR)/$(2)/modules ]; then rm -fr $$(OUTPUT_DIR)/$(2)/modules; fi
	$$(hide)cd $$(OUTPUT_DIR)/$(2) && tar xzf modules_android_mmc.tgz && cp -r modules $$(OUTPUT_DIR)/$(2)/root_nfs/system/lib/
	$$(log) "  modifying root nfs folder..."
	$$(hide)cd $$(OUTPUT_DIR)/$(2)/root_nfs && $$(MY_SCRIPT_DIR)/twist_root_nfs.sh 
	$$(log) "copy demo media files to /sdcard if there are demo media files..."
	$$(hide)if [ -d "$$(DEMO_MEDIA_DIR)" ]; then \
			mkdir -p $$(OUTPUT_DIR)/$(2)/root_nfs/sdcard && \
			cp $$(DEMO_MEDIA_DIR)/* $$(OUTPUT_DIR)/$(2)/root_nfs/sdcard/ && \
			echo "  done."; \
		   else \
			echo "    !!!demo media is not found."; \
		   fi
	$$(log) "  packaging the root_nfs.tgz..."
	$$(hide)cd $$(OUTPUT_DIR)/$(2) && tar czf root_nfs_$(1).tgz root_nfs/
	$$(log) "  done for package_droid_mmc_$(1)_$(2)."

PUBLISHING_FILES_$(2)+=$(2)/root_nfs_$(1).tgz:m:md5 
endef

# The source directory of the kernel, it should be relative to SRC_DIR
# KERNEL_SRC_DIR

#$1:build variant
define define-cp-android-root-dir-mlc
PUBLISHING_FILES_$(1)+=$(1)/root_android_mlc.tgz:m:md5 
cp_android_root_dir_mlc_$(1):
	$$(log) "[$(1)]copying root directory from $$(OUTPUT_DIR) ..."
	$$(hide)if [ -d "$$(SRC_DIR)/$$(KERNEL_SRC_DIR)/root" ]; then rm -fr $$(SRC_DIR)/$$(KERNEL_SRC_DIR)/root; fi
	$$(hide)cp -p -r $$(OUTPUT_DIR)/$(1)/root $$(SRC_DIR)/$$(KERNEL_SRC_DIR) 
	$$(hide)cd $$(SRC_DIR)/$$(KERNEL_SRC_DIR)/root && $$(MY_SCRIPT_DIR)/update_root_for_mlc.sh 
	$$(hide)mkdir -p $$(OUTPUT_DIR)/$(1)
	$$(hide)cd $$(SRC_DIR)/$$(KERNEL_SRC_DIR) && tar czf $$(OUTPUT_DIR)/$(1)/root_android_mlc.tgz root/ 
endef

#
#<os>:<storage>:<kernel_cfg>:<root>
# os: the operating system
# storage: the OS will startup from which storage
# kernel_cfg:kernel config file used to build the kernel
# root: optional. If specified, indicating that the kernel zImage has a root RAM file system.
#example: android:mlc:pxa168_android_mlc_defconfig:root
# kernel_configs:=
#
kernel_configs:=android:mlc:pxa168_android_mlc_defconfig:root 
kernel_configs+=android:mmc:pxa168_android_mmc_defconfig 
kernel_configs+=maemo:mlc:pxa168_mlc_defconfig

#
# <a list of kernel module files that will be copied and tared>
# The module file's path is relative to SRC_DIR
# modules:=
module_files:=$(KERNEL_SRC_DIR)/drivers/net/wireless/libertas/libertas.ko
module_files+=$(KERNEL_SRC_DIR)/drivers/net/wireless/libertas/libertas_sdio.ko
module_files+=$(GC300_SRC_DIR)/build/sdk/drivers/galcore.ko

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
PUBLISHING_FILES_$(2)+=$(2)/modules_$$(os)_$$(storage).tgz:m:md5

build_kernel_$$(os)_$$(storage)_$(2): private_os:=$$(os)
build_kernel_$$(os)_$$(storage)_$(2): private_storage:=$$(storage)
build_kernel_$$(os)_$$(storage)_$(2): private_root:=$$(root)
build_kernel_$$(os)_$$(storage)_$(2): private_kernel_cfg:=$$(kernel_cfg)
build_kernel_$$(os)_$$(storage)_$(2): private_root:=$$(root)
build_kernel_$$(os)_$$(storage)_$(2): output_dir $$(if $$(findstring root,$$(root)), cp_$$(os)_root_dir_$$(storage)_$(2) ) 
	$$(log) "[$(2)]starting to build kernel for booting $$(private_os) from $$(private_storage) ..."
	$$(log) "    kernel_config: $$(private_kernel_cfg): ..."
	$$(hide)cd $$(SRC_DIR)/$$(KERNEL_SRC_DIR) && \
	export ARCH=arm && \
	export CROSS_COMPILE="$$(KERNEL_TOOLCHAIN_PREFIX)" && \
	make $$(private_kernel_cfg) && \
	make clean && make 
	$$(hide)mkdir -p $$(OUTPUT_DIR)/$(2)
	$$(hide)cp $$(SRC_DIR)/$$(KERNEL_SRC_DIR)/arch/arm/boot/zImage $$(OUTPUT_DIR)/$(2)/zImage.$$(private_os).$$(private_storage) 
	$$(log) "    building gc300 driver..."
	$$(hide)export KERNEL_DIR=$$(SRC_DIR)/$$(KERNEL_SRC_DIR) && export CROSS_COMPILE="$$(KERNEL_TOOLCHAIN_PREFIX)" && \
	cd $$(SRC_DIR)/$$(GC300_SRC_DIR) && make avlite
	$$(log) "    copy module files ..."
	$$(hide)if [ -d $$(OUTPUT_DIR)/$(2)/modules ]; then rm -fr $$(OUTPUT_DIR)/$(2)/modules; fi && mkdir $$(OUTPUT_DIR)/$(2)/modules
	$$(hide)for mod in $$(module_files); do cp $$(SRC_DIR)/$$$$mod $$(OUTPUT_DIR)/$(2)/modules; done
	$$(hide)cd $$(OUTPUT_DIR)/$(2) && tar czf modules_$$(private_os)_$$(private_storage).tgz modules/ 
	$(log) "  done."

.PHONY: build_kernel_$$(os)_$$(storage)_$(2)
build_kernel_$(2): build_kernel_$$(os)_$$(storage)_$(2)
endef

$(foreach bv,$(BUILD_VARIANTS), $(eval $(call define-build-droid-kernel,$(bv)) )\
								$(eval $(call define-build-droid-root,$(bv)) ) \
								$(eval $(call define-build-droid-pkgs,$(bv)) ) \
								$(eval $(call define-build-droid-config,$(bv),internal) ) \
								$(eval $(call define-build-droid-config,$(bv),external) ) \
								$(eval $(call define-cp-android-root-dir-mlc,$(bv)) )\
								$(eval $(call rebuild-droid-config,internal,$(bv)) )\
								$(eval $(call rebuild-droid-config,external,$(bv)) )\
								$(eval $(call package-droid-mlc-config,internal,$(bv)) )\
								$(eval $(call package-droid-mlc-config,external,$(bv)) )\
								$(eval $(call package-droid-mmc-config,internal,$(bv)) )\
								$(eval $(call package-droid-mmc-config,external,$(bv)) ) \
								$(foreach kc, $(kernel_configs),$(eval $(call define-kernel-target,$(kc),$(bv)) ) )\
)

