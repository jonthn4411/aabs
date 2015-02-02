#check if the required variables have been set.
$(call check-variables, PUBLISH_DIR)

MD5_FILE:=checksums.md5
define cp-with-md5
	@echo "publishing mandatory file:$(1) to $(2)"
	@mkdir -p $(dir $(2))
	@cp -fr $(1) $(2) && chmod a+r -R $(2)
	$(if $(findstring $(strip $(3)),md5), \
		@echo "generating md5 for $(2)" && \
		cd $(dir $(1)) && \
		md5sum $(notdir $(1)) >>$(OUTPUT_DIR)/$(MD5_FILE) \
	 )
endef

define cpif-with-md5
    @echo "publishing files for $1"
    @mkdir -p $(dir $(2))
    @cp -fr $(1) $(2) || echo "$(1) not exsit"
    @chmod -R a+r $(2) || echo "$(2) not exist"
    $(if $(findstring $(strip $(3)),md5), \
        @if [ -f $1 ]; then echo "generating md5 for $(2)"; \
        cd $(dir $(1)) && \
        md5sum $(notdir $(1)) >>$(OUTPUT_DIR)/$(MD5_FILE); \
        elif [ -d $1 ]; then echo "generating md5 for $(2)"; \
        cd $(1) && \
        ls|xargs md5sum >>$(OUTPUT_DIR)/$(MD5_FILE); fi\
     )
endef

define define-publishing-file-target
tw:=$$(subst :,  , $(1) )
name:=$$(word 1, $$(tw) )
mandatory:=$$(word 2, $$(tw) )
md5:=$$(word 3, $$(tw) )

.PHONY: publish_$$(name)

publish_$$(name): private_name:=$$(name)
publish_$$(name): private_mandatory:=$$(mandatory)
publish_$$(name): private_md5:=$$(md5)
publish_$$(name): 
	$$(if $$(findstring $$(strip $$(private_mandatory)),m), \
	$$(call cp-with-md5,$$(OUTPUT_DIR)/$$(private_name),$$(PUBLISH_DIR)/$$(private_name),$$(private_md5) ), \
	$$(call cpif-with-md5,$$(OUTPUT_DIR)/$$(private_name),$$(PUBLISH_DIR)/$$(private_name),$$(private_md5) ) )

publish: publish_$$(name)
endef

define define-publishing-file-target2
tw:=$$(subst :, , $(1) )
name:=$$(word 1, $$(tw) )
dst:=$$(word 2, $$(tw) )
mandatory:=$$(word 3, $$(tw) )
md5:=$$(word 4, $$(tw) )

.PHONY: publish2_$$(name)

publish2_$$(name): private_name:=$$(name)
publish2_$$(name): private_dst:=$$(dst)
publish2_$$(name): private_mandatory:=$$(mandatory)
publish2_$$(name): private_md5:=$$(md5)
publish2_$$(name): 
	$$(if $$(findstring $$(strip $$(private_mandatory)),m), \
	$$(call cp-with-md5,$$(OUTPUT_DIR)/$$(private_name),$$(PUBLISH_DIR)/$$(private_dst)/,$$(private_md5) ), \
	$$(call cpif-with-md5,$$(OUTPUT_DIR)/$$(private_name),$$(PUBLISH_DIR)/$$(private_dst)/,$$(private_md5) ) )

publish: publish2_$$(name)

endef

define define-backup-file-target
name:=$(1)

.PHONY: backup_$$(name)

backup_$$(name): private_name:=$$(name)
backup_$$(name):
	@echo "Backup" $$(private_name)
	@echo "[aabs] [$(date)] Backup $$(private_name) to $$(BACKUP_SERVER):$$(BACKUP_DIR) start"
	@ssh -vv -P 2222 ${BACKUP_SERVER} "mkdir -p ${BACKUP_DIR}"
	@scp -P 2222 $$(OUTPUT_DIR)/$$(private_name) $$(BACKUP_SERVER):$$(BACKUP_DIR)
	@echo "[aabs] [$(date)] Backup done"

publish: backup_$$(name)

endef

.PHONY: publish_dir
publish_dir:
	$(hide)if [ -z "$(PUBLISH_DIR)" ]; then \
	  echo "Please specify export PUBLISH_DIR in shell environment."; \
	  exit 1; \
	fi
	$(hide)if [ ! -d "$(PUBLISH_DIR)" ]; then \
	    mkdir -p $(PUBLISH_DIR) && chmod g+w $(PUBLISH_DIR); \
	fi

clean_md5_file:
	@echo -n > $(OUTPUT_DIR)/$(MD5_FILE)

publish: publish_dir clean_md5_file
	@echo "Publish $(MD5_FILE)"
	@cp $(OUTPUT_DIR)/$(MD5_FILE) $(PUBLISH_DIR)

$(foreach pf, $(PUBLISHING_FILES), $(eval $(call define-publishing-file-target, $(pf) ) ) )
$(foreach pf, $(PUBLISHING_FILES2), $(eval $(call define-publishing-file-target2, $(pf) ) ) )
$(foreach pf, $(BACKUP_FILES), $(eval $(call define-backup-file-target, $(pf) ) ) )
