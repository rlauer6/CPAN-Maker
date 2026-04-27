# CPAN::Maker 1.8.1 Release Notes

## Overview

A focused bug-fix release addressing `set -euo pipefail` compatibility
in `make-cpan-dist.in`. The 1.8.0 release introduced strict shell
error handling that exposed several latent bugs in the logging
functions and variable initialization throughout the script.

## Bug Fixes

**Logging functions broken under `set -euo pipefail`.** The `ERROR`,
`INFO`, `WARN`, `DEBUG`, and `TRACE` functions all used `&&` chains
for conditional output:

```bash
[ "$LOG_LEVEL" -ge 2 ] && 2>&1 echo "INFO: $1" && return
```

Under `set -e`, a false condition in an `&&` chain propagates as a
non-zero exit and kills the script. All logging functions are now
implemented via a shared `_LOG` helper that always returns zero and
correctly handles `LOG_LEVEL` as a string by forcing arithmetic
evaluation with `$(( LOG_LEVEL + 0 ))`.

**`LOG_LEVEL` string comparison.** `LOG_LEVEL` was initialized as a
string and compared with `-ge` without coercion. The `_LOG` function
now uses `$(( $LOG_LEVEL + 0 ))` to guarantee numeric comparison.

**`cleanup` function referenced unset variables.** Several variables
used in `cleanup` - `scripts`, `resources`, `tmp_gitdir`,
`package_files`, `exe_files`, `depfile`, `workdir` - could be unset
when cleanup ran on early exit. All are now initialized with
`${var:-}` defaults.

**Missing `$` on `workdir` check in `cleanup`.** `[[ -n "workdir" ]]`
was always true - a literal string. Fixed to `[[ -n "$workdir" ]]`.

**`set -o pipeline` removed.** The `git_project` code path contained
`set -o pipeline` - not a valid bash option. Removed.

**`set -o pipefail` removed from `scan` function.** It was already set
globally via `set -euo pipefail` at the top of the script. The
redundant per-function call caused issues in some execution contexts.

**Pervasive variable initialization.** Over 25 variables across the
script were referenced before initialization, causing failures under
`-u`. All are now initialized with `${var:-}` defaults at the point of
first use or before the code blocks that reference them.

**Quoting.** Numerous variable expansions were unquoted, causing
word-splitting issues with paths containing spaces. All variable
expansions now use proper quoting.
