# CPAN::Maker 1.9.0 Release Notes

## Overview

Two goals drove this release:

1. **Migrate the build system from autoconf/automake to
   `CPAN::Maker::Bootstrapper`** - the project now builds itself using
   the same toolchain it provides to others
2. **Set the stage for retiring the bash script** while remaining
   fully compatible with all 1.x.x usage

No user-facing behavior has changed. The bash script `make-cpan-dist`
is untouched. Existing `buildspec.yml` files work without
modification.  Callers of `make-cpan-dist.pl` see identical behavior -
it now delegates to the new `cpan-maker` entry point transparently.

---

## What's New

**`cpan-maker` - new entry point**

A `CLI::Simple`-based modulino wrapper replaces the monolithic
`make-cpan-dist.pl`. The bash script `make-cpan-dist` and the shim
`make-cpan-dist.pl` both delegate to it, so existing workflows are
unaffected. Direct invocation is identical:

```bash
cpan-maker -b buildspec.yml
```

**`@bashrun@` substitution removed**

The bash script shebang previously required autoconf processing to
substitute `@bashrun@` with the path to bash. It is now hardcoded to
`#!/usr/bin/env bash`, which is more portable and eliminates a silent
failure mode when the script was installed without running `./configure`.

**`validate` - validate and normalize the `buildspec.yml` file**

Run `cpan-maker validate` to check your `buildspec.yml` against the
distributed `buildspec-schema.json` schema. If your file uses
underscore-style keys (`pm_module`, `extra_files`, etc.) they are
automatically normalized to their canonical hyphenated forms and a
corrected copy is written to `buildspec.yml.current`. Useful as a
first step when migrating an existing project or upgrading
`CPAN::Maker`.

---

## Under the Hood

**Autoconf/automake completely removed**

`configure.ac`, `bootstrap`, `directories.inc`, all `Makefile.am`
files, and the entire `autotools/` macro directory are gone. The
project is now governed by an immutable bootstrapper-managed `Makefile`
with `.includes/` for managed targets (`perl.mk`, `git.mk`, `help.mk`,
`release-notes.mk`, `update.mk`, `upgrade.mk`, `version.mk`).

**`CPAN::Maker` refactored as a `CLI::Simple` modulino**

The implementation previously embedded in `make-cpan-dist.pl` is now
in `lib/CPAN/Maker.pm`, composed from role classes:

- `CPAN::Maker::Role::FileUtils` - filesystem operations
- `CPAN::Maker::Role::ModuleUtils` - module path and version resolution
- `CPAN::Maker::Utils` - exported pure utility functions
- `CPAN::Maker::Constants` - shared constants

This decomposition is the foundation for incrementally replacing the
bash script with Perl commands in future releases, one function at a
time.

**`buildspec-schema.json` added to `share/`**

The YAML spec file used to validate `buildspec.yml` is now installed
via `File::ShareDir` rather than embedded in `__DATA__`. This makes it
inspectable and independently versionable.

**Project layout normalized**

All source files moved from `src/main/perl/` and `src/main/bash/` to
`lib/` and `bin/` respectively. Release notes consolidated under
`release/`.

**Dependencies**

Added: `CLI::Simple 2.0.0`, `CLI::Simple::Constants`, `CLI::Simple::Utils`,
`File::ShareDir`, `Role::Tiny`, `Role::Tiny::With`, `YAML::XS`

Removed: `YAML::Tiny`, `Getopt::Long`, `Log::Log4perl :easy`,
`Pod::Usage`, `Pod::Find`, `IO::Pager`

Note: `YAML::XS` is stricter than `YAML::Tiny`. Non-conformant YAML
in `buildspec.yml` files that happened to parse under `YAML::Tiny` may
require correction.
