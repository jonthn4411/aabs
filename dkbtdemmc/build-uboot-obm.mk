#check if the required variables have been set.
$(call check-variables,BUILD_VARIANTS)

define define-build-uboot-obm

.PHONY:build_uboot_obm_$(1)
build_uboot_obm_$(1):
	$$(hide)cd $$(SRC_DIR)/boot && \
	make all
endef

$(foreach bv, $(BUILD_VARIANTS), $(eval $(call define-build-uboot-obm,$(bv)) ) )

.PHONY:clean_uboot_obm
clean_uboot_obm:
	$(log) "cleaning obm and uboot..."
	$(hide)cd $(SRC_DIR)/boot && \
	make  clean_uboot
	$(log) "  clean obm and uboot  done."


