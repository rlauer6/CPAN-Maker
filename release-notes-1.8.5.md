# CPAN::Maker 1.8.4 and 1.8.5 Release Notes

## Overview

Two consecutive bug fix releases addressing unbound variable errors in
the bash script, fragile path handling in `make-cpan-dist.pl`, and CI
pipeline improvements.

---

## 1.8.5

### Bug Fixes

**`grep` exit code in dependency file generation**

The pipeline that filters `requires.tmp` into the dependency file:

```bash
awk '{print $1}' ${workdir}/requires.tmp | sort -u | grep -v '^perl' > $depfile
```

was failing with a non-zero exit code when `grep` found no matching
lines - a legitimate outcome for distributions with no non-perl
dependencies. Added `|| true` to prevent the script from aborting in
this case.

**`check_path` - warn instead of die on missing paths**

Previously `check_path` would `die` immediately if a path listed in
`buildspec.yml` under `exe_files`, `scripts`, or `tests` didn't exist,
aborting the entire build. This was too aggressive - distributions
legitimately may not have executables or test directories.

`check_path` now returns `$FALSE` and emits three warning lines
instead:

```
WARNING: ** `bin` does not exist or is inaccessible.
WARNING: ** paths should be absolute or relative to /path/to/project
WARNING: ** Consider removing entry from your buildspec.yml file if this is expected.
```

**`parse_path` - skip option if directory does not exist**

`parse_path` now checks the return value of `check_path` before adding
the option to `%args`. Previously the option was always added regardless
of whether the path existed, which could cause downstream failures even
after `check_path` was changed to warn rather than die.

---

## 1.8.4

### Bug Fixes

**Unbound variable in `make-cpan-dist`**

Another unbound variable reference in the bash script was causing
failures under `set -u`. Fixed with appropriate `${VAR:-}` defaulting.

### CI Improvements

**`build-github` generalized**

The GitHub Actions build script has been made more generic - it no
longer contains distribution-specific assumptions and can be used as a
standard template across all distributions in the toolchain.

**`build-requires` - pin `Markdown::Render` version**

`Markdown::Render` pinned to a specific version in `build-requires` to
prevent CI failures caused by pulling in an incompatible version from
CPAN.

**`.github/workflows/build.yml` - add `git`**

`git` added to the CI container package list. Required for build steps
that call `git` to determine project metadata.

**`TODO` file added** - documents the planned `make-cpan-dist` bash ->
Perl refactor and other outstanding work.
