#check if the required variables have been set.
$(call check-variables,BUILD_VARIANTS)

WTPSP_DIR:=vendor/marvell/generic/wtpsp
KERNEL_DIR:=$(SRC_DIR)/kernel/kernel
CROSS_TOOL:=$(SRC_DIR)/prebuilt/linux-x86/toolchain/arm-eabi-4.4.0/bin/arm-eabi-
GIT_PROJECT:=ssh://shgit.marvell.com/git/security/wtpsp_caddo2.git

#$1:build variant
define define-build-wtpsp
#format: <file name>:[m|o]:[md5]
#m:means mandatory
#o:means optional
#md5: need to generate md5 sum

.PHONY:build_wtpsp_$(1)
build_wtpsp_$(1):
	$$(log) "starting($(1)) to build WTPSP"
	rm -rf $(SRC_DIR)/$(WTPSP_DIR) && mkdir -p $(SRC_DIR)/$(WTPSP_DIR) && \
	git clone $(GIT_PROJECT) $(SRC_DIR)/$(WTPSP_DIR) && \
	cd $(SRC_DIR)/$(WTPSP_DIR)/drv/src && \
	make KDIR=$(KERNEL_DIR) ARCH=arm CROSS_COMPILE=$(CROSS_TOOL) && \
	cd $(SRC_DIR) && rm -rf $(SRC_DIR)/$(WTPSP_DIR)
	$$(log) "  done."
endef

$(foreach bv, $(BUILD_VARIANTS), $(eval $(call define-build-wtpsp,$(bv)) ) )

.PHONY:clean_wtpsp
clean_wtpsp:
	$(log) "cleaning WTPSP ..."
	rm -rf $(SRC_DIR)/$(WTPSP_DIR) && \
	$(log) "    done."



