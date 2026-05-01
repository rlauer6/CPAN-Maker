SUBDIRS = .

include $(top_srcdir)/directories.inc

NO_ECHO ?= @

perlrun = @ENV@ @PERL@

perlwc = @ENV@ @PERL@

# you should be using perl5libdir as the base target of your perl
# modules, not as simply part of your PERLINCLUDE
ax_perl5_extra_includes_opt = @ax_perl5_extra_includes_opt@
ax_perl5_extra_includes = @ax_perl5_extra_includes@

FILE_PERLMODULES = \
    File/Process.pm.in

FILE_PROCESS_PERLMODULES = \
    File/Process/Utils.pm.in

CPAN_PERLMODULES = \
    CPAN/Maker.pm.in

CPAN_MAKER_ROLE_PERLMODULES = \
    CPAN/Maker/Role/ModuleUtils.pm.in \
    CPAN/Maker/Role/FileUtils.pm.in

CPAN_MAKER_PERLMODULES = \
    CPAN/Maker/Utils.pm.in \
    CPAN/Maker/Constants.pm.in

PERLMODULES = \
    $(FILE_PERLMODULES) \
    $(FILE_PROCESS_PERLMODULES) \
    $(CPAN_PERLMODULES) \
    $(CPAN_MAKER_PERLMODULES) \
    $(CPAN_MAKER_ROLE_PERLMODULES)

GFILE_PERLMODULES         = $(FILE_PERLMODULES:.pm.in=.pm)
GFILE_PROCESS_PERLMODULES = $(FILE_PROCESS_PERLMODULES:.pm.in=.pm)

GCPAN_MAKER_PERLMODULES        = $(CPAN_MAKER_PERLMODULES:.pm.in=.pm)
GCPAN_MAKER_ROLE_PERLMODULES   = $(CPAN_MAKER_ROLE_PERLMODULES:.pm.in=.pm)
GCPAN_PERLMODULES              = $(CPAN_PERLMODULES:.pm.in=.pm)
GPERLMODULES                   = $(PERLMODULES:.pm.in=.pm)

G3MANPAGES = $(GPERLMODULES:.pm=.3man)

filedir = $(perl5libdir)/File
file_DATA = $(GFILE_PERLMODULES)

file_processdir = $(perl5libdir)/File/Process
file_process_DATA = $(GFILE_PROCESS_PERLMODULES)

cpandir = $(perl5libdir)/CPAN
cpan_DATA = $(GCPAN_PERLMODULES)

cpan_makerdir = $(perl5libdir)/CPAN/Maker
cpan_maker_DATA = $(GCPAN_MAKER_PERLMODULES)

dist_noinst_DATA = \
    $(FILE_PERLMODULES) \
    $(FILE_PROCESS_PERLMODULES) \
    $(CPAN_PERLMODULES) \
    $(CPAN_MAKER_PERLMODULES)

man3_MANS = $(G3MANPAGES)

@do_subst_command@

if USING_PERL5_EXTRA_INCLUDES
PERL5_EXTRA_INCLUDES = $(ax_perl5_extra_includes_opt)
else
endif

# Please see the notes concerning PERLINCLUDE in the ../bin/Makefile.am file
PERLINCLUDE = \
    -I $(builddir) \
    -I $(builddir)/../lib \
    $(PERL5_EXTRA_INCLUDES) \
    -I $(perl5libdir)

%.pm: %.pm.in
	$(NO_ECHO)test -d "$$(dirname "$@")" || $(INSTALL) -d "$$(dirname "$@")"
	$(do_subst) $< > $@
	$(perlwc) $(PERLINCLUDE) -wc $@ || { rm $@ && exit 1; }

$(GFILE_PERLMODULES): File/Process/Utils.pm

CPAN/Maker.pm: $(GCPAN_MAKER_PERLMODULES) $(GCPAN_MAKER_ROLE_PERLMODULES) CPAN/Maker/Utils.pm

CPAN/Maker/Utils.pm: CPAN/Maker/Utils.pm.in CPAN/Maker/Constants.pm

all: $(GPERLMODULES) $(G3MANPAGES) README.md

CLEANFILES = $(GPERLMODULES)

$(G3MANPAGES): %.3man : %.pm
	$(NO_ECHO)podchecker $<; \
	target_name="$@"; \
	echo $$target_name; \
	tname=$$(echo "$${target_name}" | sed -e 's/\.3man$$//') ;\
	"$(POD2MAN)"  \
	--center="$(PACKAGE)" \
	--name="$${tname}" \
	--release=$(PACKAGE)-$(VERSION) \
	--section=3man $< "$${target_name}" || touch "$${target_name}"; \
	new_name=$$(echo "$$target_name" | sed -e 's/\//::/g'); \
	echo "man: $$target_name $$new_name"

.PHONY: clean-local
clean-local:
	$(MAKE) clean-generated-man-pages

.PHONY: clean-generated-man-pages
clean-generated-man-pages:
	for f in $$(find . -name '*.3man'); do \
	  echo "$$f"; \
	  rm -f "$$f" ;\
	done

manpages: $(G3MANPAGES)

README.md: CPAN/Maker.pm
	$(NO_ECHO)pod2markdown $< > $@

AUTOMAKE_OPTIONS = no-installman

install-data-hook: $(G3MANPAGES)
	set -x;	for a in $(G3MANPAGES); do \
	  target_name=$$(echo "$$a" | sed -e 's/\//::/g'); \
	  install_dir=$(DESTDIR)$(mandir)/man3; \
	  test -d $$install_dir || mkdir -p $$install_dir; \
	  cp $(builddir)/$$a \
	     $$install_dir/$${target_name}; \
	done

uninstall-local:
	for a in $(G3MANPAGES); do \
	  target_name=$$(echo "$$a" | sed -e 's/\//::/g'); \
	  rm -f $(DESTDIR)$(mandir)/man3/$${target_name}; \
	done
