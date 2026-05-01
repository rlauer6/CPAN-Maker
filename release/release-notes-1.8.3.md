# CPAN::Maker 1.8.3 Release Notes

## Overview

A focused maintenance release improving robustness of temporary file
management in `make-cpan-dist`. All temporary file creation is now
centralized through a single `make_temp` function that registers files
for cleanup automatically, eliminating several categories of resource
leak and simplifying the `cleanup` handler.

## Changes

### `make-cpan-dist` - Temporary File Management Refactor

**New `make_temp` function** - a thin wrapper around `mktemp` that
registers every temporary file or directory in a `CLEANFILES` array:

```bash
function make_temp {
    local tmp
    tmp="$(mktemp "$@")"
    CLEANFILES+=("$tmp")
    echo "$tmp"
}
```

All `mktemp` calls throughout the script have been replaced with
`make_temp`, including:

- `filter_file_list` - `file_list_sorted`, `exclude_list_sorted`
- `get_module_versions` - `modules`
- `builddir`, `tmp_gitdir` (directory creation via `make_temp -d`)
- `package_files`, `exe_files`, `all_files`
- `resources`, `_module_index`, `sorted_provides`
- `depfile`, `testsfile`

**Refactored `cleanup` function** - replaced the previous approach of
individually guarding each named variable with a single loop over the
`CLEANFILES` array:

```bash
for item in "${CLEANFILES[@]:-}"; do
    if [[ -e "$item" ]]; then
        rm -rf "$item"
    fi
done
```

The `workdir` sweep for `*.tmp` files is retained as a separate step.
`NOCLEANUP` handling is now guarded with `${NOCLEANUP:-}` to prevent
unbound variable errors when the script exits early.

**`CLEANFILES` declared and `trap` moved** - `declare -a CLEANFILES=()`
and `trap cleanup EXIT` are now at the top of the main script body,
before any `make_temp` calls. Previously the trap was registered after
`builddir` was created, meaning early exits could leave files behind.

**Explicit `rm` calls removed** - several inline `rm` calls that were
duplicating what `cleanup` already did have been removed
(`filter_file_list`, `all_files` removal block), reducing the chance
of double-remove races.

## Bug Fixes

- `recommends_file` variable expansion fixed - was `${recommends_files:-}`
  (extra `s`), now correctly `${recommends_file:-}`
- `TEST_REQUIRES` and `BUILD_REQUIRES` variable expansions fixed -
  were missing `$` sigil (`{TEST_REQUIRES:-}` and `{BUILD_REQUIRES:-}`),
  causing them to be passed as literal strings rather than expanded
  values
- `EXEC_PATH` now quoted when assigned (`EXEC_PATH="$bindir"`) to
  guard against paths containing spaces
- Redundant `EXEC_PATH` and `SCRIPT_PATH` default assignments at the
  bottom of the script removed (already set earlier)
