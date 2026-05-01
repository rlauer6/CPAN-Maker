# CPAN::Maker Release Notes — v1.7.4

## Overview

A small patch release. One functional fix in `make-cpan-dist.pl` to
set `$INCLUDE_DOTFILES` to true. This allows `File::ShareDir::Install`
to install dot files.

---

## Bug Fixes

### `make-cpan-dist.pl` - Set `$File::ShareDir::Install::INCLUDE_DOTFILES` to 1.

From the `File::ShareDir::Install` documentation:

```
     Two variables control the handling of dot-files and dot-directories.

    A dot-file has a filename that starts with a period (.). For example
    ".htaccess". A dot-directory is a directory that starts with a period
    (.). For example ".config/". Not all filesystems support the use of
    dot-files.

  $INCLUDE_DOTFILES
    If set to a true value, dot-files will be copied. Default is false.
```
