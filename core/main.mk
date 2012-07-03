# Make sure that there are no spaces in the absolute path; the
# build system can't deal with them.
ifneq ($(words $(shell pwd)),1)
$(warning ************************************************************)
$(warning You are building in a directory whose absolute path contains)
$(warning a space character:)
$(warning $(space))
$(warning "$(shell pwd)")
$(warning $(space))
$(warning Please move your source tree to a path that does not contain)
$(warning any spaces.)
$(warning ************************************************************)
$(error Directory names containing spaces not supported)
endif

#buiding android requires this
SHELL := /bin/bash

define check-variable
temp:=$(1)
ifeq ($$(strip $$($$(temp))),)
$$(error please define the variable:$(1) before include this make file.)
endif
endef

#check if the variable list's value is empty or not
define check-variables
$(foreach var, $(1), $(eval $(call check-variable,$(var))))
endef

#check if the required variables have been set.
$(call check-variables, ABS_PRODUCT_CODE ABS_MANIFEST_BRANCH)
#ABS_RELEASE_NAME is optional

current-time:=[$$(date "+%Y-%m-%d %H:%M:%S")]
log:=@echo $(current-time)
hide:=@
space:= #a designated space

PUBLISHING_FILES:=
PUBLISHING_FILES2:=
BACKUP_FILES:=
TOP_DIR:=$(shell pwd)

SRC_DIR:=src.$(ABS_PRODUCT_CODE)
OUTPUT_DIR:=out.$(ABS_PRODUCT_CODE)
ifneq ($(strip $(ABS_RELEASE_NAME)),)
SRC_DIR:=$(SRC_DIR).$(ABS_RELEASE_NAME)
OUTPUT_DIR:=$(OUTPUT_DIR).$(ABS_RELEASE_NAME)
endif

#number of concurrent jobs for make
JOBS_FACTOR:=1.5
CPUCORES:=$(shell $(TOP_DIR)/tools/cpucount.sh)
MAKE_JOBS:=$(shell echo "scale=0; $(CPUCORES)*$(JOBS_FACTOR)/1" | bc)

#We must initialize PUBLISHING_FILES_XXX to a simply expanded flavor variable
PUBLISHING_FILES:=

#
#convert the relative directory to absolute directory.
#
OUTPUT_DIR:=$(TOP_DIR)/$(OUTPUT_DIR)
SRC_DIR:=$(TOP_DIR)/$(SRC_DIR)


#Selecting the toolchain
#default android tool
DEFAULT_CCACHE:=$(SRC_DIR)/prebuilt/linux-x86/ccache/ccache
DEFAULT_ANDROID_TOOLCHAIN:=$(SRC_DIR)/prebuilt/linux-x86/toolchain/arm-eabi-4.2.1/bin/arm-eabi-

#use the Android toolchain by default
ifeq ($(strip $(EXTERNAL_TOOLCHAIN_PREFIX)),)
    KERNEL_TOOLCHAIN_PREFIX:=$(DEFAULT_ANDROID_TOOLCHAIN)
else
    #make Android use external toolchain
    export TARGET_TOOLS_PREFIX:=$(EXTERNAL_TOOLCHAIN_PREFIX)
    KERNEL_TOOLCHAIN_PREFIX:=$(EXTERNAL_TOOLCHAIN_PREFIX)
endif

ifneq ($(strip $(USE_CCACHE) ), )
    #enable android build system to use ccache
    export USE_CCACHE:=true
    KERNEL_TOOLCHAIN_PREFIX:=$(DEFAULT_CCACHE) $(KERNEL_TOOLCHAIN_PREFIX)
endif


#by default show the help
help:

.PHONY: output_dir
output_dir:
	$(hide)if [ ! -d "$(OUTPUT_DIR)" ]; then \
	    mkdir $(OUTPUT_DIR); \
        fi

.PHONY: clobber
clobber:
	$(log) "clean source directory..."
	$(hide)sudo rm -fr $(SRC_DIR)
	$(log) "clean output directory..."
	$(hide)sudo rm -fr $(OUTPUT_DIR)
	$(log) "  done."
	
.PHONY: help
help:
	@echo "-------"
	@echo "  Auto build system for ${ABS_PRODUCT_CODE}."
	@echo "--------"
	@echo "  Targets:"
	@echo "    source: get the source code from GIT and put it in $(SRC_DIR). and save the manifest file."
	@echo "    changelog: generate the changelog from from GIT commit history. "
	@echo "    build: build the droid, kernel and uboot and obm."
	@echo "    clean: remove all the files in output directory and remove all the source files."
	@echo "    publish: copy the final targets from output directory to publishing directory."
	@echo "    pkgsrc: using manifest.xml to get the source from GIT server and package it as a tarball."
	@echo "  Settings:"
	@echo "    Manifest Repository: $(GIT_MANIFEST)"
	@echo "    Manifest Branch: $(ABS_MANIFEST_BRANCH)"
	@echo "    Kernel Toolchain: $(KERNEL_TOOLCHAIN_PREFIX)"
	@echo "    Output Directory: $(OUTPUT_DIR)"
	@echo "    Source Directory: $(SRC_DIR)"
	@echo "    Publish Directory: $(PUBLISH_DIR)"
	@echo " "


