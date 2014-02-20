
pkgsrc: save_prjlist
#pkgsrc: pkg_all_src
#pkgsrc: pkg_kernel_src
#pkgsrc: pkg_boot_src
#pkgsrc: pkg_droid_src
#pkgsrc: delta_patches
#pkgsrc: publish_setup_sh
#pkgsrc: publish_RN

#
#  Platform-specified targets
#

#
#  Clean up internal projects and avoid publishing them
#
INTERNAL_PROJECTS:=
remove_internal_src: get_source_for_pkg
	$(hide)echo "  remove internal source code..."
	$(hide)cd $(OUTPUT_DIR)/source && for prj in $(INTERNAL_PROJECTS); do rm -fr $$prj; done

pkgsrc: remove_internal_src

eden_SW_schedule: $(ABS_SOC)/Eden_Plat_SW_Schedule.xlsx
	$(hide)echo " publish matrix worksheet"
	$(hide)cp $(ABS_SOC)/Eden_Plat_SW_Schedule.xlsx $(OUTPUT_DIR)/

pkgsrc: eden_SW_schedule

