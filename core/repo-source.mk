#check if the required variables have been set.
$(call check-variables,MANIFEST_BRANCH GIT_MANIFEST GIT_REPO)

#get source code from GIT by repo
.PHONY: source
source: output_dir
	$(hide)if [ ! -d "$(SRC_DIR)" ]; then \
	    mkdir $(SRC_DIR); \
	fi
	$(log) "starting get source code from GIT server:$(GIT_SERVER), branch:$(MANIFEST_BRANCH), manifest:$(MANIFEST_FILE) ..."
	$(hide)cd $(SRC_DIR) && \
	if [ -z "$(GIT_LOCAL_MIRROR)" ]; then \
		repo init -u ssh://$(GIT_MANIFEST) -b $(MANIFEST_BRANCH) --repo-url ssh://$(GIT_REPO); \
	else \
		repo init -u ssh://$(GIT_MANIFEST) -b $(MANIFEST_BRANCH) --repo-url ssh://$(GIT_REPO) --reference $(GIT_LOCAL_MIRROR); \
	fi && \
	repo sync
	$(log) "saving manifest file..."
	$(hide)cd $(SRC_DIR) && repo manifest -r -o $(OUTPUT_DIR)/manifest.xml
#if an expection happened, repo doesn't exit with a non-zero value, we use below command to make sure the manifest.xml is generated.
	$(hide)ls $(OUTPUT_DIR)/manifest.xml > /dev/null
	$(hide)git rev-parse HEAD >$(OUTPUT_DIR)/abs.commit
	$(log) "  done."


#format: <file name>:[m|o]:[md5]
#m:means mandatory
#o:means optional
#md5: need to generate md5 sum
PUBLISHING_FILES+=manifest.xml:m
PUBLISHING_FILES+=abs.commit:m

