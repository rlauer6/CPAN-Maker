# CPAN::Maker 2.0.11 Release Notes

## Overview

This release includes bug fixes and build system improvements,
focusing on correctness in the `provides` file handling during
distribution builds and more robust dependency scanning in the
`Makefile`.

---

## What's New

### Bug Fixes

#### `CPAN::Maker` — `cmd_build`

- **Avoid unnecessary updates to `provides` in the project root.**
  Previously, `cmd_build` would unconditionally copy the `provides`
  file into the project root before invoking `write_makefile`,
  potentially overwriting an unchanged file. The `provides_file` path
  is now passed directly to `write_makefile` via a named parameter,
  eliminating the intermediate copy to the project root. The file is
  still copied into the build directory as needed.

#### `CPAN::Maker::Role::Provides` — `_write_provides`

- **Graceful handling of modules with no version.** Previously,
  `_write_provides` would `croak` if a provided module entry had no
  version string. It now silently sets the version to `undef` instead
  of dying, allowing distributions with versionless modules to build
  successfully.

---

### Build System Improvements

These changes were applied to the project's internal build
infrastructure by `CPAN::Maker::Bootstrapper`.

#### `.gitignore`

- Added patterns for additional generated and temporary files:
  `**/*.bak`, `**/*.log`, `**/*.pod`, `**/*.tmp`, `**/.\#*`, `**/\#*`,
  `cpanfile.*`, and `test-requires.scan`.

#### `.includes/local.mk`

- The `local` target now tracks installation state via a
  `local/.installed` sentinel file, allowing `make` to correctly
  detect whether local dependencies need to be (re)installed.
- Runtime dependencies (`cpanfile.runtime`) and test dependencies
  (`test-requires.cpanfile`) are now installed as separate `cpm`
  invocations, improving reliability.
- A new `test-requires.cpanfile: test-requires` rule generates a
  dedicated cpanfile for test dependencies.
- When `CPAN_INSTALLER` is not set, the build now creates the
  `local/lib/perl5` directory and touches the sentinel rather than
  exiting early without tracking state.

#### `.includes/perl.mk`

- Syntax and POD check steps now emit structured progress messages
  (e.g., `Checking SYNTAX...<file>...OK`, `Checking
  POD...<file>...OK`, `Checking TIDINESS...<file>...OK`, `Checking
  PERLCRITIC...<file>...OK`) for improved build output legibility.
- The `perlcritic` check now suppresses output to `/dev/null` on
  success, reducing noise.
- The `LOCAL_PREREQ` prerequisite now correctly points to
  `local/.installed` (the sentinel file) rather than the `local`
  directory target.

#### `Makefile`

- The `find-files` macro now accepts an optional fourth filename
  pattern argument, allowing test files matching `*.pm` and `*.pl` in
  addition to `*.t` to be included in `TESTS`.
- A new `cpanfile.runtime` target generates a runtime-only cpanfile
  from the `requires` file.
- Dependency scanning (`requires.raw`, `recommends.raw`,
  `suggests.raw`) now sets `PERL5LIB` to include `lib` and
  `local/lib/perl5`, improving scan accuracy for projects with local
  dependencies.
- Test dependency scanning is now split into two stages:
  - `test-requires.scan` — scans test files and normalises whitespace
    in the output.
  - `test-requires.raw` — filters the scan output against the
    `provides` file via `comm`.
- The `test-requires` target now depends on `test-requires.raw` directly.
- `provides` and `test-requires.scan` are now listed under
  `GENERATED_FILES` and cleaned up by `make clean`.
- `cpanfile.*` files are now removed by `make clean`.
- The `extra-files` target now validates that all listed files have
  been added to the git repository via `git ls-files --error-unmatch`
  before accepting the generated file.
- `extra-files.mk` is now included unconditionally (changed from
  `-include` to `include`) when not in bootstrap mode.

---

## Upgrade Notes

- No changes to public API or module interfaces.
- Projects that previously relied on `provides` being written to the
  project root directory during `cmd_build` should note that this
  intermediate copy no longer occurs. The `provides` file is now read
  from its original location and copied directly to the build
  directory.
- The `local` target now uses a sentinel file (`local/.installed`). If
  you have scripts or tooling that depend on the `local` target's
  behaviour, ensure they account for this change.
