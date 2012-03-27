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
build_droid_kernel:
	$(log) "build droid kernel."
	$(log) "ABS_SOC: $(ABS_SOC)"
	$(log) "ABS_DROID_BRANCH: $(ABS_DROID_BRANCH) "
	$(log) "DROID_PRODUCT: $(DROID_PRODUCT)"
	$(log) "DROID_VARIANT: $(DROID_VARIANT)"
	$(log) "Done"

##!!## build rootfs for android, make -j4 android, copy root, copy ramdisk/userdata/system.img to outdir XXX
#$1:build variant

