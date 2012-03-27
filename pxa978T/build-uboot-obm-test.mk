#check if the required variables have been set.
#$(call check-variables,BUILD_VARIANTS)
BOOT_SRC_DIR:=boot
BOOT_OUT_DIR:=$(BOOT_SRC_DIR)/out

#OBM_NTLOADER_1:=ASPN_NTLOADER_avengers-a_slc.bin
#OBM_NTLOADER_2:=ASPN_NTLOADER_spi.bin

OBM_NTIM_1:=NEVO_Loader_eMMC_ARM_3_3_1.bin
#OBM_NTIM_1:=TAVOR_SAAR_NTOBM_EMMC_MODE1.bin.rnd
#OBM_NTIM_2:=ntim_a0_avengers-a_1.6F_256mb_400mhz_mode3_pm_spi.bin

PRIMARY_GPT_BIN:=primary_gpt
SECONDARY_GPT_BIN:=secondary_gpt
PRIMARY_GPT_BIN_2:=primary_gpt_8g
SECONDARY_GPT_BIN_2:=secondary_gpt_8g

.PHONY:build_uboot_obm
build_uboot_obm:
	$(log) "build uboot obm done"

.PHONY:clean_uboot_obm
clean_uboot_obm:
	$(log) "cleaning uboot and obm..."
	$(hide)cd $(SRC_DIR)/$(BOOT_SRC_DIR) && \
	#make clean
	make clean_uboot
	$(log) "    done."



