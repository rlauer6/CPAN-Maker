# CPAN::Maker 2.0.13 Release Notes

## Overview

This release is a substantial build-system overhaul. The primary
themes are: introducing a generated `build-config.mk` to centralize
tool detection, restructuring lint and syntax checking into
batched grouped-target rules, adding an opt-in role system for
project extensions, and hardening the `builder` CI script. Most
changes affect the project build infrastructure managed by
`CPAN::Maker::Bootstrapper` rather than the `CPAN::Maker` Perl
module itself.

---

## GNU Make 4.3 Now Required

The `Makefile` now asserts at parse time that GNU Make 4.3 or newer
is available, using the `grouped-target` feature check. Projects
running older Make versions will receive an error before any rules
execute. `.SHELLFLAGS` is also now set to `-e -o pipefail -c`,
making shell recipe failures propagate reliably.

---

## New: `build-config.mk` and Bootstrap Guard

Tool detection (paths for `perl`, `perltidy`, `perlcritic`, and
related executables) has moved out of the `Makefile` into a generated
file, `build-config.mk`, produced by running `cmb create-build-config`.
This file is now included unconditionally; the previous shell-based
assignments (`CONFIG_READER`, `BASEDIR`, `SYNTAX_CHECKING`,
`PERLTIDYRC`, `PERLCRITICRC`) are removed.

A `BOOTSTRAP_BUILD` guard skips inclusion of `config.mk` and the
managed include files when `build-config.mk` is absent, allowing
the Makefile to parse cleanly in a fresh checkout before the
bootstrapper has run.

`build-config.mk` is added to `CLEANFILES` and `.gitignore`.

---

## Restructured Lint and Syntax Checking (`perl.mk`)

The per-file `%.pm`/`%.pl` sentinel rules for tidying and critic
checks have been replaced with grouped-target (`&:`) rules that
batch all files in a single invocation:

- **`$(addsuffix .tdy,...) &:`** — calls `$(BOOTSTRAPPER) perltidy
  --file-list` for all files that are out of date; skips up-to-date
  files without invoking the tool.
- **`$(addsuffix .crit,...) &:`** — same pattern for
  `$(BOOTSTRAPPER) perlcritic --file-list`.
- **`$(addsuffix .rendered,...) &:`** — new grouped rule renders all
  `.pm.in` sources to `.pm.rendered` via `$(BOOTSTRAPPER)
  resolve-vars --file-list`, replacing the previous per-file
  `%.pm: %.pm.in` rule. Templating and syntax/POD checking are now
  separate phases.

New sentinel files `PERL_CHECKED_FILES` (`.pm.checked`) and
`PERL_BIN_CHECKED_FILES` (`.pl.checked`) track syntax and POD
checking state. These are added to `CLEANFILES`.

`%.pm.checked` now depends on both `%.pm` and `%.pm.rendered`, with
POD checked against the rendered source. `check_pod` is extracted as
a separate callable `define` snippet, decoupled from the syntax
check macros. `check_syntax_pm` and `check_syntax_pl` now correctly
reference `$<` instead of `$@`.

`deps.mk` is now `include`d (required) rather than `-include`d
(optional) when `syntax_on` is active, and its self-remake rule has
moved into `perl.mk` under the same guard.

Missing `PERLTIDYRC`/`PERLCRITICRC` files are now warnings rather
than errors. Profile flags are passed only when the variable is
non-empty.

---

## New Build Targets

- **`real-quick`** — like `quick`, but also sets
  `SYNTAX_CHECKING=off`. Useful for rapid iteration.
- **`force-reconcile`** — phony target that triggers unconditional
  dependency reconciliation; also triggered automatically when any
  of `requires`, `recommends`, `suggests`, or `test-requires` are
  missing.
- **`pre-update::`** — extensible double-colon hook, called before
  the `update` target runs. Projects can add their own `pre-update::`
  rules.

---

## Dependency File Handling

`requires`, `recommends`, `suggests`, and `test-requires` are now
pattern rules that delegate to `%.reconciled` targets. A new grouped
reconcile rule drives `$(BOOTSTRAPPER) reconcile-deps` for all four
types in a single pass.

Raw dependency scanning now writes output to a temporary directory
and only replaces `*.raw` files when content has changed, avoiding
spurious rebuilds. The `provides` rule similarly avoids rewriting
when content is unchanged (`cmp -s`).

The `cpanfile.darkpan` rule now accepts an optional `darkpan.skip`
filter. `extra-files.mk` is now `-include`d (optional). `CLEANFILES`
now uses explicit `cpanfile.{recommends,requires,runtime,suggests}`
instead of a glob, and adds `*.reconciled`, `*.rendered`, and
`build-config.mk`.

---

## New Role System

Two built-in roles are added under `.roles/`:

- **`CPAN-Maker-Bootstrapper-Role-LLM`** (`role.mk` +
  `role.yml`) — provides LLM-assisted workflow targets.
- **`CPAN-Maker-Bootstrapper-Role-PAUSEUpload`** (`role.mk` +
  `role.yml`) — provides PAUSE upload workflow targets.

Role `role.mk` files under `.roles/*/` are now included automatically
via a wildcard after the bootstrap guard, making the role system
extensible without editing the main `Makefile`.

---

## Managed Include File Changes

`MANAGED_MK_FILES` is updated:

| Added | Removed |
|---|---|
| `add-plugin.mk` | `publish.mk` |
| `build-init.mk` | `release-notes.mk` |
| `builder.mk` | |
| `test.mk` | |

`INCLUDES_DIR` is now `.includes/` (with trailing slash); include
paths are constructed with `addprefix`. `INCLUDES_FILES` and
`.roles/*/role.mk` are included after the bootstrap guard. The
previous scattered `-include` directives for individual `.mk` files
are removed.

---

## `update` and `update-available` Changes (`update.mk`)

- `MANAGED_SOURCE_FILES` is now explicitly listed (`Makefile.txt`,
  `builder`, `builder.env`, `gitignore`).
- `post-update` copies `Makefile.txt` → `Makefile` and
  write-protects managed includes. It errors out if any managed file
  is missing from the dist directory.
- `update-available` now uses `case` statements instead of
  `if/else`, delegates the update check to `$(BOOTSTRAPPER)
  update-available`, and delegates the md5sums path to `$(BOOTSTRAPPER)
  --path-only dist-file`. Invalid values for `CMB_UPDATE_CHECK` or
  `CMB_VERSION_DRIFT` now produce an error. `CMB_VERSION_DRIFT`
  values (`fail`, `warn`, `ignore`) are now case-insensitive.
- `BOOTSTRAPPER_DIST_DIR` now uses `dist_dir("CPAN-Maker-Bootstrapper")`
  with a double-quoted argument for correct shell quoting.

---

## `builder` CI Script Changes

- Accepts `PROJECT_DIR` as an optional first argument (defaults to
  `pwd`). The previous `REPO`/git-clone and branch-checkout logic
  (`GITHUB_REF_NAME`/`BUILD_BRANCH`) is removed; the script now
  expects to run inside an already-checked-out project directory.
- Sources `./builder.env` (with `set -a`) if the file is present,
  allowing per-project environment overrides.
- Auto-detects `PERLTIDYRC` and `PERLCRITICRC` via `find` when not
  set in the environment; validates paths if set; errors if
  `LINT=on` but neither rc file is found.
- `Perl::Critic` and `Perl::Tidy` installation is now conditioned on
  `LINT=on`.
- Sets `PERL5LIB` to `$(pwd)/local/lib/perl5` via `set -a`.
- Build summary banner is redirected to stderr.
- The build sequence is now `make clean` → `make builder-pre` →
  `time make` → `make builder-post`, replacing the previous single
  `time make CMB_VERSION_DRIFT=ignore NO_ECHO=` invocation.

---

## New Files in the Distribution

- `suggests` — project-level suggests file (was deleted in 2.0.12,
  restored here).
- `test-requires` — project-level test-requires file (likewise
  restored).
- `.prompts/change-log.prompt` — LLM prompt for ChangeLog
  generation.

---

## `.gitignore` Updates

Added patterns: `deps.mk`, `*.reconciled`, `*.rendered`,
`build-config.mk`, `release-*.diffs`, `release-*.gz`,
`release-*.lst`, `release-*.status`. Added `!cpanfile.darkpan` to
un-ignore that file.

---

