# CPAN-Maker 2.0.12 Release Notes

## Overview

This release focuses on build system improvements and dependency
cleanup. It introduces DarkPan support, refines dependency scanning
and filtering, and removes redundant entries from the module's
dependency list.

## What's New

### DarkPan Support

The build system now supports installations that require modules from
a private DarkPan mirror. Set `DARKPAN_REQUIRES=1` and
`DARKPAN_URL=<url>` in your `config.mk` to enable generation of
`cpanfile.darkpan` and `cpanm.darkpan` artifacts.

### Improved Dependency Filtering

The `test-requires` and general dependency scanning targets have been
refactored to use a new `deps-filter` step via the bootstrapper
(`cmb`), which filters out redundant sub-module dependencies. Versions
of `0` in scanned output are now normalized to `undef`.

### Dependency Cleanup

Redundant dependencies that are already pulled in transitively have
been removed from `requires` and `cpanfile`:

- `CLI::Simple::Constants` (included via `CLI::Simple`)
- `CLI::Simple::Utils` (included via `CLI::Simple`)
- `Log::Log4perl::Level` (included via `Log::Log4perl`)
- `Role::Tiny::With` (included via `Role::Tiny`)

The empty `suggests` and `test-requires` files have been removed.

### `extra-files` Skip List Support

The `extra-files` target now respects an `extra-files.skip` file,
allowing specific files to be excluded from distribution file
validation without causing build failures.

### New `test-local` Hook

A phony `test-local` extensibility hook has been added to the `test`
target, allowing projects to inject additional test steps without
modifying the main `Makefile`.

### Extensible Tarball Prerequisites

A new `TARBALL_ORDER_ONLY_PREREQS` variable allows projects to inject
order-only prerequisites into the tarball build target via
`config.mk`.

## Build System Changes

This release includes updates to the managed build infrastructure
provided by `CPAN::Maker::Bootstrapper`:

- `publish.mk` has been added to `.includes/`
- `update.mk` has been updated with a cleaner separation between
  managed Makefile includes (`MANAGED_MK_FILES`) and other managed
  files (`MANAGED_FILES`)
- `include .includes/publish.mk` has been added to the root
  `Makefile`

---

## ChangeLog Inconsistencies and Omissions

The following issues were noted when reviewing the ChangeLog entry
for 2.0.12:

1. **`Makefile` changes under-described**: The ChangeLog attributes
   `Makefile` changes to `CPAN::Maker::Bootstrapper` updates, but the
   diff shows substantial logic additions (DarkPan support,
   `test-local` hook, `TARBALL_ORDER_ONLY_PREREQS`,
   `deps-filter` integration, `extra-files.skip` support) that were
   authored locally, not simply propagated from the bootstrapper.

2. **`test-requires.raw` target change not mentioned**: The change
   from filtering against `provides` in `test-requires.raw` to doing
   so in the `test-requires` target itself is a meaningful behavioral
   change not called out in the ChangeLog.

3. **`extra-files` skip list not mentioned**: The addition of
   `extra-files.skip` support in the `extra-files` target is absent
   from the ChangeLog.

4. **`test-local` hook not mentioned**: The new phony `test-local`
   extensibility target is not documented.

5. **`TARBALL_ORDER_ONLY_PREREQS` not mentioned**: The new
   configurable variable for injecting order-only tarball
   prerequisites is absent.

6. **`*.darkpan` added to `CLEANFILES`**: Not mentioned in the
   ChangeLog.

---

