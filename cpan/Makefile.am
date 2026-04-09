SUBDIRS = .
#-*- mode: makefile; -*-

SHELL := /bin/bash

.SHELLFLAGS := -ec

PACKAGE_VERSION = $(shell cat $(top_srcdir)/VERSION)

MODULE_NAME  ?= $(shell SOURCE=$(top_srcdir) perl -MCwd=abs_path -MFile::Basename=basename -e '$$m=basename(abs_path($$ENV{SOURCE})); $$m =~s/\-/::/g; print $$m')

PROJECT_NAME = $(shell echo $(MODULE_NAME) | sed -e 's/::/-/g;')

TARBALL = $(PROJECT_NAME)-$(PACKAGE_VERSION).tar.gz

CPAN_DIST_MAKER=$(top_srcdir)/src/main/perl/bin/make-cpan-dist.pl

PERL5LIBDIR = $(top_builddir)/src/main/perl/lib

BINDIR = $(top_builddir)/src/main/bash/bin:$(top_builddir)/src/main/perl/bin

all: $(TARBALL)

$(TARBALL): buildspec.yml
	@cd $(top_srcdir); \
	$(MAKE)

	@test -n "$$DEBUG" && set -x; \
	test -n "$$DEBUG" && DEBUG="--debug"; \
	test -e requires && REQUIRES="-r requires"; \
	test -n "$(NOCLEANUP)" && NOCLEANUP="--no-cleanup"; \
	test -n "$(DRYRUN)" && DRYRUN="--dryrun"; \
	test -n "$(SCANDEPS)" && SCANDEPS="-s"; \
	test -n "$(NOVERSION)" && NOVERSION="-n"; \
	PROJECT_ROOT="--project-root $$(readlink -f ..)"; \
	PERL5LIB=$$PERL5LIB:$(PERL5LIBDIR) PATH=$(BINDIR):$$PATH perl $(CPAN_DIST_MAKER) $$PROJECT_ROOT $$REQUIRES $$DRYRUN \
	   $$SCANDEPS $$NOVERSION $$NOCLEANUP $$DEBUG -b $< || false \
	echo $@

.PHONY: cpan
cpan: $(TARBALL)

CLEANFILES = \
    extra-files \
    provides \
    resources 

clean-local:
	for a in $(CLEANFILES); do \
	  rm -f $$a || true; \
	done
	rm -f *.tar.gz
	rm -f *.tmp
	find . -maxdepth 1 -name 'CPAN-Maker*' -type d -exec rm -rf {} \;

