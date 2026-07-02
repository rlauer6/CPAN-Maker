# CPAN::Maker 2.0.1 Release Notes

**Release Date:** 2026-07-02

## Overview

This is a patch release that adds the new `create-cpanfile` command to
`cpan-maker`, along with a new `--outfile` option and related
documentation updates.

---

## What's New

### New Command: `create-cpanfile`

A new subcommand that generates a `cpanfile` from one or more
plain-text dependency list files.

```
cpan-maker create-cpanfile file1 file2 ...
```

#### Input Format

Each input file contains one dependency per line:

```
Module::Name version [dist=name] [url=URL] [mirror=URL]
```

#### Behaviour

- Lines beginning with `#` are treated as comments and ignored.
- A leading `+` on a module name (as used in
  `CPAN::Maker::Bootstrapper` dependency files to pin a version) is
  stripped before processing.
- Duplicate entries are removed and the output is sorted
  alphabetically.
- The optional `dist=`, `url=`, and `mirror=` qualifiers map to the
  corresponding `cpanfile` source directives, allowing dependencies to
  be pinned to a specific distribution, URL, or mirror.

#### Examples

```bash
# Write to cpanfile (default)
cpan-maker create-cpanfile requires test-requires

# Write to STDOUT
cpan-maker create-cpanfile -o - requires > cpanfile

# Write to a named file
cpan-maker create-cpanfile -o my-cpanfile requires test-requires
```

---

### New Option: `--outfile` / `-o`

Controls the output destination for the `create-cpanfile` command.

| Value | Behaviour |
|-------|-----------|
| *(omitted)* | Writes to `cpanfile` in the current directory |
| `-` | Writes to STDOUT |
| *filename* | Writes to the specified file path |

---

## Changes

### `lib/CPAN/Maker.pm`

- Added `cmd_create_cpanfile` subroutine implementing the new command.
- Added `outfile|o=s` to the option specification list.
- Registered `create-cpanfile` in the command dispatch table.
- Added `uniq` to the imports from `List::Util`.
- Updated POD documentation throughout:
  - New `create-cpanfile` section under **Commands**.
  - New `-o, --outfile` entry under **Options** and **Option Details**.
  - Synopsis updated to include the new command.
  - Version string updated to `2.0.1`.

---

## Upgrade Notes

This release is fully backwards compatible. Existing `buildspec.yml`
files and build workflows are unaffected. The `create-cpanfile`
command is purely additive.

---

## Bug Fixes

None.

---

## Dependencies

No new runtime dependencies. `List::Util` (already a dependency) now
additionally imports `uniq`.
