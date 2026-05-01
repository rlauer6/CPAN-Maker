# CPAN::Maker Release Notes — v1.7.3

## Overview

A small patch release. One functional fix in `make-cpan-dist` to
prevent `ExtUtils::Manifest` from applying its default skip list, plus
documentation and README corrections.

---

## Bug Fixes

### `make-cpan-dist` — Explicit `MANIFEST.SKIP` to suppress default skip list

After `Makefile.PL` runs, `make manifest` was previously subject to
`ExtUtils::Manifest`'s built-in default skip list, which could silently
exclude files from the distribution. A minimal `MANIFEST.SKIP` is now
written immediately before `make manifest` runs, restricting skipped
entries to only `Makefile`, `MANIFEST.SKIP`, `MYMETA.json`, and
`MYMETA.yml`. This gives the buildspec full control over what ends up
in the distribution.

---

## Documentation

### POD (`CPAN::Maker`) and `README.md`

- **`PRESERVE_MAKEFILE`** — description clarified to note that the
  `Makefile.PL` is preserved *after* the build completes, and that its
  primary use is inspecting the build result.

- **`SKIP_TESTS`** — corrected a copy-paste error where the description
  incorrectly described `PRESERVE_MAKEFILE` behaviour. Now correctly
  documents that setting this variable skips tests during the build.

- **`DEBUG`** — reworded for accuracy; "go off script" removed in
  favour of describing what the variable actually helps with.

- **Invocation description** — the sentence describing what happens
  when the script is called without `--buildspec` was reworded for
  clarity.

### `README.md`

- Leading `.` removed from the `# README` heading (was rendering as
  `.# README` in some Markdown renderers).
- `!! NEW !!` wrapped in italics for proper Markdown rendering.
- Missing trailing `README` entry added to the table of contents.
- Truncated `cpanm` example command fixed: trailing `.` removed from
  `CPAN-Maker-1.7.2.tar.`.
