# CPAN::Maker Release Notes — Version 1.7.1

**March 17, 2026 · TBC Development Group**

---

## Overview

1.7.1 is a performance release. The `make-cpan-dist` bash script received a targeted
optimization that reduced build times for large distributions from **31 seconds to 7 seconds**
— a 4x improvement. The root cause was a repeated `find | grep` subprocess storm in
`module2path` that fired once per entry in the `provides` list. For a distribution like
`Bedrock-Core` with 158 provides entries, that meant thousands of subprocess forks on every
build. The fix replaces the per-module traversal with a single indexed scan.

Also new in this release: a `release-notes` Makefile target that generates the diff assets
needed to produce release notes.

---

## Performance Fix — `module2path` Replaced with Indexed Lookup

### The Problem

When building a distribution with an explicit `provides:` list in `buildspec.yml`
(i.e. `recurse: no`), the bash script previously called `module2path` once per module to
resolve each module name to a file path. `module2path` worked by:

1. Running `find` to traverse the entire library tree
2. Running `grep -q "^package $module;"` against **every `.pm` file found**

For a distribution with 158 provides entries and 149 `.pm` files in the tree, this meant
roughly **158 `find` invocations + ~23,500 `grep` subprocess forks** on every build. At
even 1ms per subprocess, that's 23+ seconds in process spawning overhead alone — which is
exactly what profiling confirmed.

### The Fix

`module2path` is replaced by two new functions:

**`build_module_index`** — traverses the library tree exactly once, reading every `.pm` file
with a single persistent Perl process and writing a flat index of `package-name → file-path`
entries:

```bash
function build_module_index {
    local root="$1"
    local index_file="$2"

    find -L "$root" -not -path '*/.git/*' -type f -name '*.pm' | \
        perl -ne '
            chomp;
            my $f = $_;
            open my $fh, "<", $f or next;
            while (<$fh>) {
                if (/^package\s+([\w:]+)/) {
                    print "$1 $f\n";
                }
            }
            close $fh;
        ' > "$index_file"
}
```

**`module2path_indexed`** — looks up a single module name in the pre-built index using
`awk`, falling back to direct path derivation if not found:

```bash
function module2path_indexed {
    local module="$1"
    local index_file="$2"
    local root="$3"

    local hit
    hit=$(awk -v m="$module" '$1 == m { print $2; exit }' "$index_file")

    if [[ -n "$hit" ]]; then
        echo "${hit##$root}"
        return
    fi

    # fallback: direct path derivation
    echo "$module" | perl -npe 's/::/\//g; s/\n//' | sed 's/$/.pm/'
}
```

The build loop now builds the index once before iterating the provides list:

```bash
_module_index=$(mktemp)
root="${PROJECT_HOME}/${perl5libdir}/"
build_module_index "$root" "$_module_index"

for a in $(cat $provides); do
    if [[ -n "$a" ]]; then
        echo "${PROJECT_HOME}/${perl5libdir}/$(module2path_indexed $a $_module_index $root)" >> $package_files
    fi
done

rm "$_module_index"
```

### Why the Index Handles Multi-Package Files Correctly

The original `module2path` used `grep -m1` which would only find the first `package`
declaration in a file. The new `build_module_index` reads every line of every file, so
multi-package files — such as those in the `TagX::*` family where a single `.pm` file
declares several packages — are fully indexed. Every `package` declaration gets an entry.

### Measured Results

| Version | Build time |
|---|---|
| 1.7.0 (original `module2path`) | ~31s |
| 1.7.1 (indexed lookup) | ~7s |

Profiling breakdown for `Bedrock-Core` (158 provides entries, 149 `.pm` files):

| Phase | Time |
|---|---|
| `build_module_index` | 0.45s |
| cp-loop (158 files) | 0.30s |
| `make-cpan-dist.pl` | 0.88s |
| `perltidy` (if enabled) | 0.89s |
| `perl Makefile.PL` | 0.33s |
| `make manifest` | 0.06s |
| `make dist` | 1.66s |
| **Total** | **~4.6s** |

---

## `.git` Exclusion Added to All `find` Calls

All `find` invocations in the script now include `-not -path '*/.git/*'` to prevent
accidentally traversing the git object store. For projects with long histories this can
contain tens of thousands of objects and meaningfully slow down any `find` that doesn't
exclude it. Affected calls:

- Library tree scan (`-type f -name '*.pm'`)
- Executables scan (`-type f -executable`)
- Test files scan (`-type f -name '*.t'`)

---

## New `release-notes` Makefile Target

A new `release-notes` target in `Makefile.am` automates the generation of diff assets
between the last tagged release and the current version:

```makefile
release-notes:
    @curr_ver=$(VERSION); \
    last_tag=$$(git tag -l '[0-9]*.[0-9]*.[0-9]*' --sort=-v:refname | head -n 1); \
    diffs="release-$$curr_ver.diffs"; \
    diff_list="release-$$curr_ver.lst"; \
    diff_tarball="release-$$curr_ver.tar.gz"; \
    echo "Comparing $$last_tag to current $$curr_ver..."; \
    git diff --no-ext-diff "$$last_tag" "$$curr_ver" > "$$diffs"; \
    git diff --name-only --diff-filter=AMR "$$last_tag" "$$curr_ver" > "$$diff_list"; \
    tar -cf - --transform "s|^|release-$$curr_ver/|" -T "$$diff_list" | gzip > "$$diff_tarball"; \
    ls -alrt release-$${curr_ver}*.*
```

Running `make release-notes` produces three files:

- `release-<version>.diffs` — full unified diff against the last tag
- `release-<version>.lst` — list of added/modified/renamed files
- `release-<version>.tar.gz` — tarball of the changed files

---

## Files Changed

- `src/main/bash/bin/make-cpan-dist.in` — `build_module_index` and `module2path_indexed`
  added; `module2path` removed; `.git` exclusions added to all `find` calls
- `Makefile.am` — new `release-notes` target
- `VERSION` — bumped to 1.7.1

---

*CPAN::Maker 1.7.1 · TBC Development Group · https://github.com/rlauer6/make-cpan-dist*
