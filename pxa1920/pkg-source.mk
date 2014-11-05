
pkgsrc: save_prjlist
pkgsrc: pkg_all_src
pkgsrc: pkg_kernel_src
pkgsrc: pkg_boot_src
pkgsrc: pkg_droid_src
#pkgsrc: delta_patches
pkgsrc: publish_setup_sh

#
#  Clean up internal projects and avoid publishing them
#
INTERNAL_PROJECTS +=vendor/marvell/external/gps_sirf
INTERNAL_PROJECTS +=vendor/marvell/generic/apps/CmmbPlayer
INTERNAL_PROJECTS +=vendor/marvell/generic/apps/CmmbStack
remove_internal_src: get_source_for_pkg
	$(hide)echo "  remove internal source code..."
	$(hide)cd $(OUTPUT_DIR)/source && for prj in $(INTERNAL_PROJECTS); do rm -fr $$prj; done

pkgsrc: remove_internal_src

#
#  Platform-specified targets
#
PUBLISHING_FILES+=release_package_list:o
platform_target: output_dir
	$(hide)cp $(BOARD)/release_package_list $(OUTPUT_DIR)/release_package_list

pkgsrc: platform_target