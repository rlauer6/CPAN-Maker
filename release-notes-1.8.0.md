---

# CPAN::Maker 1.8.0 Release Notes

## Bug Fixes

**Executable scripts were incorrectly assigned to `MAN3PODS` instead
of `MAN1PODS`.** Scripts in `bin/` belong in manual section 1, not
section 3. This misassignment has been present since February 2026 and
had the additional effect of suppressing automatic `MAN3PODS`
generation for `.pm` files - when `MAN3PODS` is explicitly set in
`WriteMakefile`, MakeMaker treats it as the complete list and stops
scanning `lib/` entirely. As a result, distributions built during this
period were silently shipped without man pages for their modules. This
release corrects both issues: scripts with POD are now correctly
placed in `MAN1PODS`, and `.pm` files get man pages again via
MakeMaker's default scanner.

Scripts without POD - such as bash modulino wrappers - are now
correctly excluded from `MAN1PODS` entirely.

## New Features

**`man-links` buildspec key.** Modulino wrapper scripts typically
contain no POD of their own - their documentation lives in the module
they invoke. The new `man-links` key generates `install ::` postamble
rules that create symbolic links in `$(INSTALLMAN3DIR)`, allowing `man
foo-bar` to resolve to the man page for `Foo::Bar`:

```yaml
man-links:
  - foo-bar: Foo::Bar
  - bootstrapper: My::Module
```

Links are registered in the distribution `.packlist` so they are
removed cleanly on uninstall. If the target module has no POD the link
is silently skipped.
