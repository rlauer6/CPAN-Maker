# CPAN::Maker 2.0.5 Release Notes

**Release Date:** 2026-07-20
**Distribution:** CPAN-Maker
**Version:** 2.0.5

---

## Overview

This release delivers two categories of improvements: a bug fix in
`cmd_create_cpanfile` that prevented uninitialized-value warnings
under certain inputs, and a significant overhaul of the build system's
syntax-checking infrastructure to make incremental builds more robust
and correct.

---

## Bug Fixes

### `cmd_create_cpanfile`: Prevent Uninitialized Variable Warnings

- **`lib/CPAN/Maker.pm.in`** — The `cmd_create_cpanfile` method was
  using hash-slice notation (`@{$req}{qw(module version)}`) in
  `sprintf` calls, which could produce `Use of uninitialized value`
  warnings when either `module` or `version` was absent in a parsed
  entry. Both arguments are now accessed individually with the
  defined-or operator (`//`) to provide safe empty-string fallbacks:

  ```perl
  # Before
  sprintf qq{requires "%s", "%s";\n}, @{$req}{qw(module version)};

  # After
  sprintf qq{requires "%s", "%s";\n}, $req->{module} // q{}, $req->{version} // q{};
  ```

- A missing semicolon was also corrected in the `else` branch of the
  same method, where the first `sprintf` for multi-attribute requires
  entries was not terminated with `;\n`.

- The `close $fh` call is now wrapped in an explicit `if` block for
  clarity and correctness when `outfile` is set to `'-'` (stdout).

---

## Build System Improvements

### Syntax Checking Decoupled into a Separate Pass

**`.includes/perl.mk`** has been substantially refactored to separate
module/script *templating* (`.pm.in` → `.pm`) from *syntax checking*,
using dedicated sentinel files.

#### Problem Solved

Previously, syntax checking ran inline at the end of the `%.pm` and
`%.pl` pattern rules. This caused two interrelated problems:

1. **GNU Make intermediate-file deletion** — Make treated generated
   `.pm` and `.pl` files as disposable intermediate files in a chain
   and silently deleted them after use, even though they are primary
   build deliverables.
2. **`deps.mk` bootstrap deadlock** — `deps.mk` (which lists
   inter-module dependencies) needs all `.pm` files to exist before it
   can be regenerated. If syntax checking ran during templating, and a
   freshly-added `use` referenced a sibling module not yet built, the
   build would fail before `deps.mk` could be updated.

#### Solution

- Templating rules (`%.pm`, `%.pl`) now only perform substitution and
  write the output file. Syntax checking is removed from these rules
  entirely.
- New sentinel rules (`%.pm.checked`, `%.pl.checked`) perform `perl
  -wc` compilation and `podchecker` validation *after* all modules are
  already on disk. Sentinels are simple empty files whose timestamps
  track whether a check has been run.
- A new explicit `check-syntax` phony target depends on all
  `.pm.checked` and `.pl.checked` sentinels, and is now a named
  dependency of the tarball build target.
- `.PRECIOUS: %.pm %.pl` is declared to prevent Make from deleting
  these files as intermediates.
- Sentinel files (`*.checked`) are added to `CLEANFILES` and ignored in `.gitignore`.

#### `compile.skip` Support

The skip-list logic for syntax checking now supports a `compile.skip`
file in the project root in addition to the `PERLWC_SKIP` make
variable. Entries from both sources are merged at check time.

#### `syntax_on` Variable Simplified

The `syntax_on` variable no longer has a dependency on `lint_off`; it
is now evaluated independently:

```makefile
# Before
syntax_on = $(if $(lint_off),,$(filter-out off,...))

# After
syntax_on = $(filter-out off,...)
```

### `deps.mk` Auto-Generation

A new `deps.mk` file provides inter-module dependency edges for Make:

```makefile
deps.mk: $(PERL_MODULES)
    $(NO_ECHO)cmb create-deps > $@
```

- `deps.mk` is included conditionally — skipped for `clean` and
  `distclean` goals to prevent Make from unnecessarily rebuilding all
  `.pm` files only to immediately delete them.
- `project.mk` continues to be included unconditionally so that
  `clean-local::` hooks always run.

### Tarball Target: `check-syntax` and `--skip-tests`

- The `$(TARBALL)` target now explicitly depends on `check-syntax`.
- The `SKIP_TESTS` environment variable is now forwarded to
  `cpan-maker` as `--skip-tests`, providing a supported mechanism for
  skipping the test suite during distribution builds.

### `tidy` Target

The `tidy` target now invokes `make check-syntax` rather than
rebuilding all modules directly, keeping it consistent with the new
two-pass architecture.

---

## New Files

| File | Description |
|------|-------------|
| `deps.mk` | Auto-generated inter-module dependency edges for GNU Make |
| `release-notes/release-notes-2.0.5.md` | This release notes document |

---

## Changed Files

| File | Change Summary |
|------|----------------|
| `lib/CPAN/Maker.pm.in` | Bug fix in `cmd_create_cpanfile` |
| `.includes/perl.mk` | Syntax-check refactor; sentinel rules; `deps.mk` include guard |
| `Makefile` | `check-syntax` dependency; `deps.mk` rule; `SKIP_TESTS` forwarding |
| `VERSION` | Bumped to `2.0.5` |
| `.gitignore` | Added `**/*.checked` |
| `ChangeLog` | Updated |

---

## Upgrading

No changes to the public API or module interface. Consumers of
`CPAN::Maker` as a library are unaffected. Projects using the
`Makefile`/`perl.mk` build infrastructure should run `make clean`
before the first build after upgrading to clear any stale intermediate
files.
