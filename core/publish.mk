#check if the required variables have been set.
$(call check-variables, BUILD_VARIANTS)

MD5_FILE:=checksums.md5
define cp-with-md5
	@echo "publishing mandatory file:$(2)"
	@mkdir -p $(dir $(2))
	@cp $(1) $(2) && chmod a+r $(2)
	$(if $(findstring $(strip $(3)),md5), \
		@echo "generating md5 for $(2)" && \
		cd $(dir $(1)) && \
		md5sum $(notdir $(1)) >>$(OUTPUT_DIR)/$(MD5_FILE) \
	 )
endef

define cpif-with-md5
	@if [ -f $(1) ]; then echo "publishing optional file:$(2)"; mkdir -p $(dir $(2)) && cp $(1) $(2) && chmod a+r $(2); fi
	$(if $(findstring $(strip $(3)),md5), \
		@if [ -f $1 ]; then echo "generating md5 for $(2)"; \
		cd $(dir $(1)) && \
		md5sum $(notdir $(1)) >>$(OUTPUT_DIR)/$(MD5_FILE); fi\
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
	$$(call cp-with-md5, $$(OUTPUT_DIR)/$$(private_name), $$(PUBLISH_DIR)/$$(private_name), $$(private_md5) ), \
	$$(call cpif-with-md5, $$(OUTPUT_DIR)/$$(private_name), $$(PUBLISH_DIR)/$$(private_name), $$(private_md5) ) )

publish: publish_$$(name)
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

$(foreach bv, $(BUILD_VARIANTS), $(foreach pf, $(PUBLISHING_FILES_$(bv)), $(eval $(call define-publishing-file-target, $(pf) ) ) ) )

