SUBDIRS = . src
#-*- mode: makefile; -*-

SHELL := /bin/bash

.SHELLFLAGS := -ec

PACKAGE_VERSION = $(shell cat $(top_srcdir)/VERSION)

MDUTILS = @MDUTILS@

ACLOCAL_AMFLAGS = -I autotools

README.md: README.md.in
	$(MDUTILS) $< > $@

dist_noinst_DATA = \
    ChangeLog \
    README.md.in \
    README.md

VERSION = $(PACKAGE_VERSION)

include release-notes.mk
