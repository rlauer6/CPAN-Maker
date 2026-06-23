# CPAN::Maker 1.9.2 Release Notes

## Summary

Maintenance release with correctness fixes in `lib/CPAN/Maker.pm.in`.

---

## Changes

### `lib/CPAN/Maker.pm.in`

**`_generate_man_links` - DESTDIR support and failure tolerance**

The `install ::` postamble now uses `$(DESTINSTALLMAN3DIR)` instead of
`$(INSTALLMAN3DIR)` so that `make install DESTDIR=...` packaging (e.g.
in RPM/deb build roots) resolves symlink targets correctly.  A `-`
prefix on the `ln` command makes the postamble failure-tolerant in
environments where the man page may not have been installed.

**`parse_project` - uninitialized-value safety**

Refactored to use an early return when `$project` is false, eliminating
the outer conditional.  Author name defaults to `'anonymouse'` when
`name` is absent, preventing uninitialized-value warnings.  Local
variables are used for each field before appending/formatting.

**`parse_pm_module` - early return refactor**

Equivalent early-return refactor for symmetry with `parse_project`.
