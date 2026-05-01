#-*- mode: makefile; -*-

MANAGED_FILES = \
    git.mk \
    help.mk \
    version.mk \
    perl.mk \
    release-notes.mk

BOOTSTRAPPER_DIST_DIR := $(shell perl -MFile::ShareDir=dist_dir \
    -e 'print dist_dir(q{CPAN-Maker-Bootstrapper})' 2>/dev/null)

.PHONY: update

INCLUDES_DIR = .includes

.PHONY: post-update
post-update: 
	@mkdir -p $(INCLUDES_DIR); \
	for f in $(MANAGED_FILES); do \
	  src="$(BOOTSTRAPPER_DIST_DIR)/$$f"; \
	  test -e "$$src" || continue; \
	  chmod +w "$(INCLUDES_DIR)/$$f"; \
	  cp "$$src" "$(INCLUDES_DIR)/$$f"; \
	done; \
	echo "Files updated. Review changes with: git diff"

.PHONY: update  ## update managed project files from the installed bootstrapper
update:
	chmod +w Makefile
	chmod +w .includes/*
	cp $(BOOTSTRAPPER_DIST_DIR)/Makefile.txt Makefile
	cp $(BOOTSTRAPPER_DIST_DIR)/update.mk .includes/
	cp $(BOOTSTRAPPER_DIST_DIR)/upgrade.mk .includes/
	chmod +w Makefile .includes/*
	$(MAKE) post-update

