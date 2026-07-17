# CPAN::Maker 2.0.3 Release Notes

**Release Date:** 2026-07-17
**Distribution:** CPAN-Maker-2.0.3

---

## Overview

This release delivers build system improvements via an updated
`CPAN::Maker::Bootstrapper`, adds POD validation to the Perl syntax
checking pipeline, introduces a new `--color` CLI option with colour
output disabled by default, and hardens the bootstrapper version-drift
detection workflow.

---

## What's New

### New `--color` CLI Option

`CPAN::Maker` now accepts a `--color` flag on the command
line. Coloured log output is **disabled by default** (previously it
was enabled by default). Pass `--color` explicitly to re-enable it.

```bash
# coloured output disabled by default
cpan-maker -l info -b buildspec.yml

# opt in to colour
cpan-maker -l info --color -b buildspec.yml
```

The `Makefile` build rule respects the `NO_COLOR` variable: colour is
passed through to `cpan-maker` unless `NO_COLOR` is set.

---

## Build System Changes (CPAN::Maker::Bootstrapper updates)

### `perl.mk` — POD Validation Added

Syntax checking for both `.pm` and `.pl` files now includes a
`podchecker` pass. If POD errors are detected (beyond "does not
contain any POD" or a clean "OK"), the build fails and the offending
file is removed. The `PODCHECKER` tool is auto-detected via `command
-v podchecker`.

### `update.mk` — Bootstrapper Version-Drift Detection

The `update-available` target has been significantly enhanced:

- **Update check** is now gated by the `CMB_UPDATE_CHECK` variable
  (default: `on`). Set to any other value to skip the CPAN version
  check.
- **Version-drift check** compares local bootstrapper files against
  the installed version using MD5 checksums
  (`cmb_md5sums.txt`). Controlled by `CMB_VERSION_DRIFT`:
  - `fail` *(default)* — exits with an error if local files have
    drifted from the installed bootstrapper.
  - `warn` — prints a warning but continues.
  - `ignore` — skips the drift check entirely.

```makefile
# config.mk example
CMB_UPDATE_CHECK  = on
CMB_VERSION_DRIFT = warn
```

### `git.mk` — Improvements

- `NO_COMMIT=1` can now be set to stage files without committing.
- `git init` output is suppressed (`>/dev/null`).
- `make clean` is called as part of initialisation.
- Fixed shell quoting and continuation syntax throughout the target.

### `Makefile` — General Improvements

- Added `-include config.mk` to support per-project configuration
  overrides.
- `BOOTSTRAPPER_VERSION` now uses `CPAN::Maker::Bootstrapper->VERSION`
  (method call form).
- `DEPS` changed from `=` to `+=` assignment, allowing additive
  extension.
- `update-available` added as a build dependency so drift/update
  checks run automatically.
- `buildspec.yml` is now written with explicit `chmod 0644`.
- Added `clean-local` phony target (double-colon rule) for
  project-specific clean hooks.
- `cmb_md5sums.txt` added to `CLEANFILES`.
- `NO_COLOR` variable introduced (empty by default).
- `CMB_UPDATE_CHECK` and `CMB_VERSION_DRIFT` defaults defined in the
  Makefile.

---

## Dependency Changes (`cpanfile`)

- `Module::CPANfile` entry moved to maintain alphabetical ordering (no
  version change).

---

## Bug Fixes

- Colour defaulting to `on` in `CPAN::Maker`'s Log4perl initialisation
  has been corrected to `off`.

---

## Upgrade Notes

- If you maintain a project using `CPAN::Maker::Bootstrapper`, run
  `make update` after installing this release to pull in the updated
  `.includes/*.mk` files.
- If `CMB_VERSION_DRIFT` is not set in your `config.mk`, the default
  is now `fail`. Set it to `warn` or `ignore` in `config.mk` if you
  prefer a softer check during the transition.
- `podchecker` must be available in `PATH` for POD validation during
  builds. Install via your system package manager or `cpanm
  Pod::Checker`.

---

## Files Changed

| File | Change |
|---|---|
| `lib/CPAN/Maker.pm.in` | Default colour to off; add `--color` option |
| `.includes/perl.mk` | Add `podchecker` integration to syntax checking |
| `.includes/update.mk` | Enhanced version-drift and update-check logic |
| `.includes/git.mk` | `NO_COMMIT` support; suppress `git init` output |
| `Makefile` | `config.mk` include; `DEPS +=`; `clean-local`; `NO_COLOR`; drift defaults |
| `cpanfile` | Reorder `Module::CPANfile` entry alphabetically |
| `VERSION` | Bumped to `2.0.3` |
