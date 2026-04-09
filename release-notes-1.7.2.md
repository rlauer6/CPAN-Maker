# CPAN::Maker 1.7.2 Release Notes

**Release Date:** 2026-04-09

## Overview

A maintenance release with several bug fixes, build system
improvements, and documentation updates. The most significant change
is support for distributing `.pod` files alongside `.pm` files -
a prerequisite for the `Amazon::API` 2.2.0 architecture where shape
documentation is distributed as `.pod` files separate from
dynamically-generated shape classes.

---

## Changes

### `make-cpan-dist` (bash script)

**`.pod` file support** - the file scanner now includes `.pod` files
alongside `.pm` files when collecting distribution files:

```bash
find -L ${PROJECT_HOME}/${perl5libdir} \
     -not -path '*/.git/*' -type f \
     \( -name '*.pm' -o -name '*.pod' \) > $package_files
```

`.pod` files are included in the distribution tarball but correctly
excluded from the `provides` index and dependency scanning - only
`.pm` files declare packages and require scanning.

**`module2path` restored** - the `module2path` function had been
inadvertently removed. It is restored alongside the existing
`module2path_indexed` function.

**Dependency scanning** - only `.pm` files are now scanned for
dependencies, preventing false positives from `.pod` files being
passed to the scanner. Improved messaging when no dependency file
is found.

**`cpanfile` support** - improved warning message when
`cpanfile-dump` is not found, now suggests installing
`Module::CPANfile`.

### Build system (`Makefile.am`, `cpan/Makefile.am`)

- `cpan/Makefile.am` refactored - tarball target now uses proper
  `$(TARBALL)` variable derived from module name and version rather
  than hardcoded values
- `cpan` target is now a phony alias for `$(TARBALL)`
- `SUBDIRS` typo fixed - was `SUBDIRScd` in
  `src/main/perl/bin/Makefile.am`
- `release-notes.mk` extracted from `Makefile.am` into a separate
  includable file - now shared across projects via `include
  release-notes.mk`
- `SHELL := /bin/bash` and `.SHELLFLAGS := -ec` added for consistent
  shell behavior
- Removed legacy version format handling (`n.m.r-b`) from
  `cpan/Makefile.am`

### `configure.ac`

Added checks for two new optional dependencies:

- `Module::CPANfile` - for `cpanfile` dependency format support
- `Module::ScanDeps::Static` - for static dependency scanning

### `make-cpan-dist.pl`

`--help` now shows only the `USAGE` section via `pod2usage` rather
than the full POD, making it more useful as a quick reference.

### `CPAN/Maker.pm` (POD)

- `=head1 OPTIONS` renamed to `=head1 USAGE` with a synopsis example
- Added explicit `USAGE` section with command examples for
  `pod2usage` compatibility
- Repository URLs updated from `make-cpan-dist` to `CPAN-Maker`
- `extra-files` documentation clarified - added `CAUTION` note about
  directory inclusion behavior and the `extra: manifest` alternative
- `share` directory inline annotations added to examples
- Minor prose improvements throughout

### `.gitignore`

Added `*.diffs` and `*.lst` to ignore release artifact files.

---

## Bug Fixes

- `module2path` function restored after inadvertent removal
- `SUBDIRS` typo (`SUBDIRScd`) in `src/main/perl/bin/Makefile.am`
  prevented the bin directory from being built correctly
- `.pod` files no longer passed to dependency scanner, preventing
  spurious dependency detection

---

## Dependencies

Two new optional dependencies checked in `configure.ac`:

- `Module::CPANfile`
- `Module::ScanDeps::Static`
