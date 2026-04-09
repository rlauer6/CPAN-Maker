SUBDIRS = .

include $(top_srcdir)/directories.inc

perlrun = @ENV@ perl

perlwc = @ENV@ perl

# you should be using perl5libdir as the base target of your perl
# modules, not as simply part of your PERLINCLUDE
ax_perl5_extra_includes_opt = @ax_perl5_extra_includes_opt@
ax_perl5_extra_includes = @ax_perl5_extra_includes@

# this is where we will install perl scripts
libexecdir = @libexecdir@

PERLSCRIPTS = \
    make-cpan-dist.pl.in

GPERLSCRIPTS = $(PERLSCRIPTS:.pl.in=.pl)
G1MANPAGES = $(GPERLSCRIPTS:.pl=.1man)

libexec_SCRIPTS = $(GPERLSCRIPTS)
bin_SCRIPTS = $(GPERLSCRIPTS)
dist_noinst_DATA = $(PERLSCRIPTS)

man1_MANS = $(G1MANPAGES)

@do_subst_command@

if USING_PERL5_EXTRA_INCLUDES
PERL5_EXTRA_INCLUDES = $(ax_perl5_extra_includes_opt)
else
endif

PERLINCLUDE = \
    -I $(builddir) \
    -I $(builddir)/../lib \
    $(PERL5_EXTRA_INCLUDES) \
    -I $(perl5libdir)

$(GPERLSCRIPTS): % : %.in
	test -d "$$(dirname "$@")" || $(INSTALL) -d "$$(dirname "$@")"
	$(do_subst) $< > $@
	$(perlwc) $(PERLINCLUDE) -wc $@ || { rm $@ && exit 1; }
	test -e $@ && chmod +x $@

all:

CLEANFILES = $(GPERLSCRIPTS) $(G1MANPAGES)

$(G1MANPAGES): %.1man : %.pl
	target_name="$@" ;\
	tname=$$(echo "$${target_name}" | sed -e 's/\.1man$$//') ;\
	"$(POD2MAN)" $< \
	--center="$(PACKAGE)" \
	--name="$${tname}" \
	--release=$(PACKAGE)-$(VERSION) \
	--section=1man > "$${target_name}" || true

.PHONY: clean-local
clean-local:
	$(MAKE) clean-generated-man-pages


.PHONY: clean-generated-man-pages
clean-generated-man-pages:
	for mpath in $(G1MANPAGES); do \
	rm -f "$${mpath}" ;\
	test $$? -eq 0 || exit 1 ;\
	done
