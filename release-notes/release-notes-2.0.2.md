# CPAN::Maker 2.0.2 Release Notes

**Release Date:** Mon Jul 6, 2026
**Distribution:** CPAN-Maker-2.0.2

---

## Summary

This is a patch release focused on a critical bug fix for a process
I/O deadlock that surfaced during builds of large distributions, along
with several build tooling improvements inherited from
`CPAN::Maker::Bootstrapper`.

---

## Bug Fixes

### Critical: Fixed IPC Deadlock in `_run_cmd` on Large Builds

**`lib/CPAN/Maker.pm`** — `_run_cmd`

A classic `IPC::Open3` deadlock was identified and resolved. The
previous implementation opened separate pipes for `STDOUT` and
`STDERR` and drained them sequentially. When a child process produced
more output than the kernel pipe buffer (~64K) on the second stream,
both the child and parent would block indefinitely, waiting on each
other.

**Root cause:** Sequential draining of two separate pipes. If the
first pipe never reaches EOF (because the child is blocked writing to
the second), the parent never reads the second — deadlock.

**Fix:** The child's `STDERR` is now merged into `STDOUT` via
`'>&STDOUT'` in the `open3` call, eliminating the second pipe
entirely. A single read loop drains the combined output stream.

```perl
# Before (deadlock-prone):
my $err = gensym;
my $pid = open3( my $in, my $out, $err, @cmd );

# After (deadlock-free):
my $pid = open3( my $in, my $out, '>&STDOUT', @cmd );
```

This issue was previously hidden for small distributions where output
stayed within pipe buffer limits. It was reliably triggered by larger
APIs (e.g. CloudFront) whose `make manifest` and `make dist` steps
produce sufficient output to fill a pipe buffer.

> **Note:** Do not "fix" this by enabling autoflush — that does not
> address pipe capacity. If separate `STDERR`/`STDOUT` streams are
> required in the future, use `IPC::Run3`, which spools each stream to
> a temp file.

---

## Build Tooling Changes

These changes affect the project's own build infrastructure
(`.includes/perl.mk`, `Makefile`, `builder`, `release-notes.mk`) and
are maintained by `CPAN::Maker::Bootstrapper`. They do not affect the
installed module API.

### `perl.mk`

- **Tool availability guards:** `tidy_on` and `critic_on` variables
  are now only evaluated when `perltidy` and `perlcritic` are detected
  on `PATH`, respectively. Previously, these could produce errors or
  unexpected behaviour when the tools were absent.
- **`PODEXTRACT` guard:** `run_podextract` now emits a clear error
  message and exits if `Pod::Extract` is not installed, rather than
  failing silently.
- **`check_syntax_pl` fix:** Removed spurious `-M"$$module"` flag from
  the `.pl` syntax check invocation. Plain scripts do not have an
  associated module name to load.
- **`diff` redirect fix:** Corrected a doubled redirect (`2>/dev/null
  2>&1` → `2>/dev/null`) in the perltidy diff check for `.pl` files.
- **`PODEXTRACT` variable removed** from `perl.mk` (now resolved
  directly where needed).

### `Makefile`

- **Renamed `make-cpan-dist.pl` → `cpan-maker`:** All references to
  `MAKE_CPAN_DIST` / `make-cpan-dist.pl` updated to `CPAN_MAKER` /
  `cpan-maker`.
- **`cpanfile` generation:** Now delegates to `cpan-maker
  create-cpanfile` rather than an inline `perl` one-liner.
- **`MODULE_NAME` fix:** Corrected shell variable expansion (`$(pwd)`
  → `$$(pwd)`) to ensure proper evaluation inside `$(shell ...)`.
- **`SCAN` default:** `SCAN` is now automatically set to `OFF` when
  `scandeps-static.pl` is not found on `PATH`, avoiding confusing
  errors on systems without the scanner installed.
- **`BOOTSTRAPPER` hard requirement:** The `Makefile` now emits a
  fatal error (via `$(error ...)`) if `CPAN::Maker::Bootstrapper` is
  not installed.
- **`Markdown::Render` warning:** A non-fatal `$(warning ...)` is
  emitted when `md-utils.pl` is not found, advising installation.
- **`README.md` targets:** Both `README.md` build rules are now
  guarded — they warn gracefully and fall back to copying the source
  file if `Markdown::Render` or `Pod::Markdown` are not installed,
  rather than failing the build.
- **`git config` errors suppressed:** `GIT_NAME`, `GIT_EMAIL`, and
  `GITHUB_USER` lookups now redirect `stderr` to `/dev/null`.
- **`module.pm.tmpl` / `$(MODULE_PATH).in` targets:** Improved
  template lookup using `File::ShareDir`, proper dependency ordering
  changed from order-only (`|`) to a regular prerequisite, and the
  template is cleaned up after use.
- **`buildspec.yml` template:** Removed the `@EXTRA_FILES@`
  substitution (no longer needed).
- **Default goal changed:** `.DEFAULT_GOAL` is now the tarball target
  directly (`$(TARBALL)`), rather than `all`.
- **`DEPS` variable** moved earlier in the `Makefile` for clarity.

### `builder` (CI script)

- **Installer verbosity:** Default `INSTALLER` now includes
  `--show-build-log-on-failure --verbose` flags.
- **Conditional tool installation:** `Perl::Critic` and `Perl::Tidy`
  are now only installed when `PERLCRITICRC` and `PERLTIDYRC` are set
  in the environment, respectively.
- **Core dependencies updated:** `EXTRA_DEPS` now includes
  `CPAN::Maker`, `CPAN::Maker::Bootstrapper`, `File::ShareDir`,
  `File::ShareDir::Install`, `Pod::Markdown`, and `Markdown::Render`
  in place of the previous `YAML::Tiny`-only list.
- **Clone guard:** `git clone` is skipped if the target directory
  already exists, preventing errors on re-runs.

### `release-notes.mk`

- The `release-notes` target has been simplified to delegate entirely
  to `bootstrapper release-notes`, removing the previous inline shell
  logic for generating diff archives. Output is now a Markdown file at
  `release-notes/release-notes-{version}.md`.

---

## Files Changed

| File | Change |
|------|--------|
| `lib/CPAN/Maker.pm.in` | Bug fix: merge STDERR into STDOUT in `_run_cmd` to prevent deadlock |
| `.includes/perl.mk` | Tool availability guards, syntax check fix, diff redirect fix |
| `.includes/release-notes.mk` | Simplified to delegate to `bootstrapper release-notes` |
| `Makefile` | Tool renaming, graceful degradation, variable and target fixes |
| `builder` | Conditional deps, verbosity, clone guard |
| `VERSION` | Bumped `2.0.1` → `2.0.2` |
| `ChangeLog` | Updated |

---

## Upgrading

```bash
cpanm CPAN::Maker
```

No changes to the public API. Existing `buildspec.yml` files remain fully compatible.
