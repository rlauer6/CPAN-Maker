
## The Call Chain

```
User invokes make-cpan-dist.pl -b buildspec.yml
  → Perl: parse_buildspec() reads YAML, builds %args
  → Perl: translates %args to single-letter CLI flags
  → Perl: exec 'make-cpan-dist ' . join(' ', %args)    ← back to bash
    → Bash: getopts parses those flags back into variables
    → Bash: does file gathering, scanning, temp dir setup
    → Bash: assembles $cmd array, calls make-cpan-dist.pl again (no -b)
      → Perl: write_makefile() generates Makefile.PL, prints to STDOUT
      → Bash: captures that as $builddir/Makefile.PL
      → Bash: cd $builddir && perl Makefile.PL && make manifest && make dist
```

The structured data round-trips through three serialization/deserialization steps: YAML → Perl hash → shell flags → bash variables → another Perl invocation. Every hand-off is a place where information can be lost, misquoted, or misinterpreted — and already has been (the `TEST_REQUIRES`/`BUILD_REQUIRES` missing `$` bugs, the `recommends_files` typo).

---

## What Each Script Actually Owns

**The bash script does:**
- File discovery (`find` for `.pm`, executables, tests)
- Module index building (`grep` across `.pm` files)
- Dependency scanning (calls `@PERL_REQUIRES@` which is a Perl script)
- Filtering file lists (`comm`, `sort`)
- Temp file management (now via `make_temp`)
- Git project cloning
- Building the `$builddir` directory tree
- Running `perl Makefile.PL && make manifest && make dist && make test`
- Its own parallel logging system (`ERROR`, `WARN`, `INFO`, `DEBUG`, `TRACE`)

**The Perl script does:**
- YAML parsing and validation
- `buildspec` → CLI flags translation (`parse_buildspec`)
- `Makefile.PL` generation (`write_makefile`)
- Module version resolution
- `provides` file generation
- `extra-files` expansion
- `man-links` postamble generation

The bash script's work is almost entirely things Perl handles naturally. The only genuinely bash-native step is the final `make manifest && make dist`.

---

## The Core Problems

**1. `parse_buildspec` is an abstraction inversion.** It takes a clean, structured YAML hash and degrades it into single-letter flags for a shell command. The entire purpose of moving to YAML was to escape exactly this. The output of `parse_buildspec` looks like:

```perl
$args{'-a'} = "'Rob Lauer <rob@example.com>'";
$args{'-m'} = 'My::Module';
# ... 20 more single-letter flags
```

...which gets joined into a string and passed to bash's `getopts`. This is going backwards.

**2. The logging system is duplicated.** Bash has `ERROR`/`WARN`/`INFO`/`DEBUG`/`TRACE` functions that mirror `Log::Log4perl` in Perl. The log level has to be converted between Perl's numeric Log4perl levels and bash's 1–5 integer, passed across the exec boundary, then reconverted. Neither side trusts the other's output.

**3. Temp file hygiene is split.** The bash script now uses `CLEANFILES` array + `make_temp`, but also uses `${workdir}/*.tmp` files that are cleaned separately. The Perl side uses `File::Temp`. Three cleanup strategies.

**4. `module2path` and `get_module_versions` are both O(n×m).** `module2path` greps every `.pm` file for every module lookup. `get_module_versions` spawns a new `perl` process per module to resolve versions. These are called in loops.

**5. The bash `scan()` function calls a compiled-in path.** `@PERL_REQUIRES@` is substituted at build time from the installed path of `scandeps-static.pl`. If that path changes or the user wants to override it, they're editing a generated script.

---

## Refactor Plan

The goal is: **`make-cpan-dist.pl` becomes the sole entry point. The bash script is reduced to a thin shim or eliminated.**

**Phase 1 — Eliminate the round-trip (highest value, contained change)**

Replace `exec 'make-cpan-dist ' . $cmd` in `main()` with a direct Perl call. Instead of `parse_buildspec` producing CLI flags, it produces a `%options` hash that gets passed directly to the build pipeline:

```perl
# Today:
my %args = parse_buildspec(%options);   # produces -a, -m, -b flags
exec 'make-cpan-dist ' . join(' ', %args);

# After:
my %build_options = parse_buildspec(%options);  # produces named options
run_build(%build_options);             # calls Perl functions directly
```

`run_build` would call the same operations the bash script currently does, but as Perl functions. `write_makefile` already exists and works — that half is already in Perl.

**Phase 2 — Port the file gathering to Perl**

The bash file-gathering logic maps directly to Perl:

| Bash | Perl replacement |
|---|---|
| `find ... -name '*.pm'` | `File::Find::find` |
| `build_module_index` | `Module::Metadata->new_from_file` |
| `module2path` + grep | `Module::Metadata`, hash lookup |
| `filter_file_list` + `comm` | `List::Util` or plain hash diff |
| `executables()` + `find -executable` | `File::Find` + `-x` test |
| `get_module_versions` perl spawns | Inline `Module::Metadata` or `require` |

`Module::Metadata` is already in your dep tree via `CPAN::Maker::Bootstrapper`. It replaces `build_module_index`, `module2path`, and the grep-based version resolution in one shot.

**Phase 3 — Port dependency scanning**

`scan()` calls `@PERL_REQUIRES@` which is `scandeps-static.pl`. That's already a Perl program. Replace the shell invocation with a direct call to `Module::ScanDeps::Static` programmatically — or at minimum, call it via `IPC::Run` with captured output, which is cleaner than the current string-concatenation approach.

**Phase 4 — Port the build directory management**

```perl
# The bash build dir setup becomes:
use File::Temp qw(tempdir);
use File::Copy qw(cp);
use File::Path qw(make_path);

my $builddir = tempdir(CLEANUP => 1);
make_path("$builddir/lib/...", "$builddir/bin", "$builddir/t");
cp $source, "$builddir/lib/$relative_path" for @package_files;
```

**Phase 5 — Reduce bash to a runner**

After Phases 1–4, the bash script's remaining responsibility is:

```bash
cd $builddir
perl Makefile.PL
make manifest && make dist
cp *.tar.gz $destdir
make test
```

That's 10 lines. At that point the bash script either becomes an internal helper called by `system()` from Perl, or those `make` invocations move into Perl via `IPC::Run` or `system()` and the bash script disappears entirely.

---

## What To Keep In Perl vs. What Changes

| Current location | Keep/Move |
|---|---|
| `write_makefile` | Keep, already correct |
| `get_provides` + `get_module_version` | Keep, refine |
| `parse_buildspec` | Keep structure, change output from flags to named hash |
| `write_extra_files`, `write_resources`, `write_pl_files` | Keep |
| `validate_object` | Keep |
| `get_requires` | Keep |
| `parse_buildspec` → `exec bash` | **Eliminate** |
| Bash file gathering | **Port to Perl** |
| Bash dependency scanning | **Port to Perl** |
| Bash logging | **Eliminate**, use `Log::Log4perl` throughout |
| Bash temp file management | **Eliminate**, use `File::Temp` throughout |
| Bash `make manifest/dist/test` | **Keep as system() calls from Perl** |

---

## Sequencing Recommendation

Don't do this all at once. The safest sequence is:

1. **Phase 1 first** — eliminate the round-trip. This gives you the biggest maintainability win and immediately removes the flag-serialization/deserialization bug surface. The bash script still does its work, but it's now called as a library function with a structured interface rather than via a reconstructed command line.

2. **Phase 2 next** — port file gathering. This is the bulk of the bash script and the part most likely to have edge cases. Port one function at a time with the bash equivalent still available as fallback.

3. **Phases 3–5** follow naturally once 1 and 2 are stable.

The 1.8.3 `make_temp` refactor you just did is actually good preparation for Phase 5 — it means when you eventually replace the bash cleanup with `File::Temp`'s `CLEANUP => 1`, the behavior is already well-defined and tested.
