# CPAN::Maker 2.0.0

**Released:** Mon Jun 29 2026

## Overview

Version 2.0.0 is a major release that replaces the external bash build
script (`make-cpan-dist`) with a native Perl build pipeline running
entirely within `cpan-maker`. No external bash scripts are required or
invoked during the build. Bug fix where default options were not being set.

---

## Breaking Changes

### `make-cpan-dist` bash script removed

The `make-cpan-dist` bash script has been removed from the
distribution. Projects that invoked it directly must migrate to:

```
cpan-maker -b buildspec.yml
```

The `make-cpan-dist.pl` shim is retained and now simply delegates to
`cpan-maker` (`exec 'cpan-maker', @ARGV`) to avoid breaking existing
`Makefile` targets that call it.

### `--scandeps` / `-s` option removed

Automatic dependency scanning via `scandeps.pl` was a feature of the
bash script and is no longer supported. Projects that relied on it
should provide explicit `requires` and `test-requires` dependency
files.

### Environment variables no longer honoured

The following environment variables were read by the bash script and
are no longer consulted:

| Old environment variable | Replacement CLI option  |
|--------------------------|-------------------------|
| `PRESERVE_MAKEFILE`      | `--preserve-makefile`   |
| `SKIP_TESTS`             | `--skip-tests`          |
| `DEBUG`                  | `--debug`               |

---

## New Features

### Native Perl build pipeline (`cmd_build`)

`cpan-maker -b buildspec.yml` now runs the full build pipeline
in-process:

1. Parse and validate the buildspec
2. Stage distribution files (`lib/`, `bin/`, `t/`, extra-files,
   postamble) into a `File::Temp` temporary build directory
3. Generate `Makefile.PL` in the build directory
4. Execute `perl Makefile.PL`, `make manifest`, `make dist`, and
   optionally `make test` via `IPC::Open3`
5. Copy the resulting tarball to the destination directory

Each build step streams stdout to the logger at `info` level and
stderr at `warn` level.

### New command-line options

| Option                | Description                                                                 |
|-----------------------|-----------------------------------------------------------------------------|
| `--destdir`           | Destination directory for the finished tarball. Defaults to `cwd`.          |
| `--no-cleanup`        | Preserve the temporary build directory after the build for inspection.      |
| `--preserve-makefile` | Copy the generated `Makefile.PL` to `--destdir` after the build.           |
| `--skip-tests`        | Skip `make test` during the build.                                          |

### New internal methods

**`stage_distribution`** — stages `lib/`, `bin/`, `t/`, extra-files,
and postamble into the temporary build directory. Executables are
discovered by directory scan (using the `-x` file test) and a temp
file listing their staged paths is written for `write_makefile` to
consume as `EXE_FILES`.

**`_run_cmd`** — wraps `IPC::Open3` to execute build steps, routing
stdout to the logger at `info` level and stderr at `warn` level.

**`_apply_buildspec_args`** — maps the shell-flag `%args` hash
returned by `parse_buildspec` to `$self` accessors so that
`write_makefile` has the values it needs without requiring changes to
`parse_buildspec`.

### `write_makefile` — `dest` parameter

`write_makefile` now accepts a named `dest` parameter: a file path
(written directly to disk) or a filehandle reference (written to the
handle). Defaults to `\*STDOUT`, preserving the existing behaviour of
the `write-makefile` command.

### `write-makefile` command — now a developer tool

The `write-makefile` command now generates a `Makefile.PL` to STDOUT
from command-line options, making it useful for inspecting generated
output without running a full build:

```
cpan-maker write-makefile -m Foo::Bar -r requires -a 'A. U. Thor <au@example.com>'
```

### `buildspec.yml` — `man-links`

The `man-links` section is now populated in the distribution's own
`buildspec.yml`, generating a `man3` symlink so that `man cpan-maker`
resolves to the `CPAN::Maker` man page.

### Bug Fix

In `main()` the default options hash was incorrectly being passed as
`default_option` instead of `default_options`. Specifically
`require_versions` was defaulting to false resulting in no version
numbers being pinned in `Makefile.PL`.

---

## Documentation

The POD has been substantially rewritten:

- All references to the bash script and the `USING THE BASH SCRIPT`
  section have been removed.
- The `ENVIRONMENT VARIABLES` section documents the deprecated
  variables and their CLI replacements.
- The `write-makefile` command is now described as a developer
  inspection tool rather than an internal build step.
- Option descriptions and the build specification format reference have
  been revised for accuracy and clarity.
- `=encoding UTF-8` declaration added.

---

## Migration Guide

| Before (≤ 1.9.x)                          | After (2.0.0)                          |
|-------------------------------------------|----------------------------------------|
| `make-cpan-dist -b buildspec.yml`         | `cpan-maker -b buildspec.yml`          |
| `PRESERVE_MAKEFILE=1 cpan-maker ...`      | `cpan-maker --preserve-makefile ...`   |
| `SKIP_TESTS=1 cpan-maker ...`             | `cpan-maker --skip-tests ...`          |
| `cpan-maker -s ...` (scandeps)            | Provide an explicit `requires` file    |
| `make-cpan-dist -o /tmp ...`              | `cpan-maker --destdir /tmp ...`        |
| `make-cpan-dist -x ...` (no cleanup)     | `cpan-maker --no-cleanup ...`          |
| `make-cpan-dist -p ...` (preserve)        | `cpan-maker --preserve-makefile ...`   |
