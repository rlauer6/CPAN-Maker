# NAME

CPAN::Maker - create a CPAN distribution

# SYNOPSIS

    make-cpan-dist.pl options

    make-cpan-dist.pl -b buildspec.yml

# DESCRIPTION

Utility that is part of a toolchain to create a CPAN distribution.

This utility should normally be called with the `--buildspec` option
specifying a YAML file that describes the distribution to be
packaged. The toolchain can:

- find Perl module dependencies in your modules and scripts
- create a `Makefile.PL`
- package your artifacts from your project hierarchy into a CPAN distribution

If the script is passed a YAML file (`--buildspec`) then the script
will parse the build specification and call the bash script
`make-cpan-dist` with all of the necessary flags to build a
tarball. If you do not provide a build specification this script will
only create the `Makefile.PL` file for you.  It will be left to you
to modify the `Makefile.PL` if necessary and then package the
artifacts into a CPAN distribution.

You can also call the bash script yourself, supplying all of the
necessary options.  When [using the bash script](#using-the-bash-script), it will ultimately call this script to create the
`Makefile.PL` and before creating your CPAN distribution.

# USAGE

    make-cpan-dist.pl -b buildspec.yml

    make-cpan-dist.pl options

## Options

    -a, --author                author
    -A, --abstract              description of the module
    -B, --build-requires        build dependencies
    -b, --buildspec             read a buildspec and create command line
        --cleanup, --no-cleanup remove temp files, default: cleanup
        --create-buildspec      name of a buildspec file to create
    -d, --debug                 debug mode
        --dryrun                dryrun
        --exe-files             path to the executables list
        --extra-path            path to the extra files list
    -h, --help                  help
    -l, --log-level             ERROR, WARN, INFO, DEBUG, TRACE
    -m, --module                module name
    -M, --min-perl-version      minimum perl version to consider core, default: $PERL_VERSION
    -P, --pager, --no-pager     use a pager for help, default: use pager
        --pl-files              path to the PL_FILES list (see perldoc ExtUtils::MakeMaker)
        --postamble             name of the file containing the postamble instructions
    -p, --project-root          default: current working directory
        --recurse               whether to recurse directors when searching for files
    -r, --requires              dependency list
    -R, --require-versions      add version numbers to dependencies
        --no-require-versions   
        --scripts-path          path to the scripts listing
    -t, --test-requires         test dependencies
        --tests-path            path to the tests listing
    -s, --scandeps              use scandeps for dependency checking
    -V, --verbose               verbose output
    -v, --version               version
        --version-from          module name that provide version

This script is typically called with the `--buildspec` option
specifying a YAML file that contains the options for building a CPAN
distribution.  Calling this script without the `--buildspec` option
will only result in a `Makefile.PL` being written to STDOUT.

When invoked with a buildspec it will parse the YAML file and call the
`make-cpan-dist` bash script that actually creates the CPAN
distribution.

See man CPAN::Maker for more details.

# ENVIRONMENT VARIABLES

- PRESERVE\_MAKEFILE

    Set this environment variable to a true value if you want the script
    to preserve the `Makefile.PL` after it builds the distribution
    (useful for inspecting the result of the build). It will be copied to
    your current working directory.

- SKIP\_TESTS

    Set this environment variable to skip tests during the build.

- DEBUG

    Set this environment variable to enable debug mode. The bash script
    will echo all commands run. This is useful for debugging unexpected
    output or problems with the final distribution.

    See https://github.com/rlauer6/CPAN-Maker.git for more documentation.

# VERSION

This documentation refers to version 1.7.5

# USING THE BASH SCRIPT

Assuming you have a module named `Foo::Bar` in a directory named
`lib` and some tests in a directory named `t`, you might try:

    make-cpan-dist -l lib -t t -m Foo::Bar \
     -a 'Rob Lauer <rlauer6@comcast.net>' -d 'the Foo::Bar module!'

_NOTE: Running the Bash script in any directory of your project if it
is part of a `git` repository will use the root of the repository as
your project home directory.  If you are not in a `git` repository
AND do not supply the -H option (project home), then the current
directory will be considered the project home directory. This means
that options like -l will be relative to the current directory._

## Using `buildspec.yml`

    make-cpan-dist.pl -b buildspec.yml

Calling this utility directly with the `-b` option will parse the
buildspec and invoke the `bash` script with all of the appropriate
options. This is the preferred way of using this toolchain. The format
of the YAML build file is described below.

_IMPORTANT: All files specified in the `buildspec.ym` file must be
specified as absolute paths or they should be relative to the
project's root directory, **NOT THE CURRENT WORKING DIRECTORY!**_

# OPTION DETAILS

- -A, --abstract

    A short description of the module purpose.

- -a, --author

    When supplying the author on the command line, include the email
    address in angle brackets as shown in the example.

    Example: -a 'Rob Lauer <rlauer6@comcast.net>'

    If this is a _git_ project then the bash script will attempt to get
    your name and email from the git configuration.

- -B, --build-requires

    Name of the file that contains the dependencies for building the distribution.

- -b, --buildspec

    Name of build specification file in YAML format.  The build
    specification file will be parsed and supply the necessary options to
    the bash script for creating your distribution.  See ["BUILD SPECIFICATION FORMAT"](#build-specification-format).

- -c, --cleanup

    Cleanup temp directories and files.  The default is to cleanup all
    temporary files, use the `--no-cleanup` option if you want to examine
    some of the temporary files.

- -C, --create-buildspec

    Name of a buildspec file to create from the options passed to this
    script.

    _Note that this file may need to be modified if the options passed to
    the file are not sufficient to create an acceptable buildspec._

- -d, --debug

    Debug mode. Outputs lot's of diagnostics for debugging the
    interpretation of the options passed and the `Makefile.PL` creation
    process.

- --dryrun

    Typically used when calling the bash script directly, this will output
    the command to be executed and all of the options to
    `make-cpan-dist.pl`.

- -h, --help

    Print the options to `make-cpan-dist.pl` to STDOUT. For more help try
    `make-cpan-dist -h` for the options to the bash script.

    Additional information can be found
    [here](https://github.com/rlauer/make-cpan-dist)

- -l, --log-level

    Log level.

    Valid values: error|warn|info|debug

    default: error

- -m, --module

    Name of the Perl module to package.

- -M, --min-perl-version

    The minium version of perl to consider core when resolving dependencies.

- -P, --pager, --no-pager

    Use a pager for help.

    default: --pager

- --pl-files

    Path to the PL\_FILE list.

    From: https://metacpan.org/pod/ExtUtils::MakeMaker

    _MakeMaker can run programs to generate files for you at build time. By
    default any file named \*.PL (except Makefile.PL and Build.PL) in the
    top level directory will be assumed to be a Perl program and run
    passing its own basename in as an argument. This basename is actually
    a build target, and there is an intention, but not a requirement, that
    the \*.PL file make the file passed to to as an argument. For
    example..._

        perl foo.PL foo

- --postamble

    Name of a file that contains the `Makefile.PL` postamble section.

- -p, --project-root

    Root of the project to use when looking for files to package.

    default: current working directory

- --recurse

    Recurse sub-directories when looking for files to package.

- -r, --requires

    Name of a file that contains the list of dependencies if other than `requires`.

    default: requires

- -R, --require-versions, --no-require-versions

    Whether to add version numbers to dependencies.

    default: --require-versions

- -s, --scandeps

    Use `scandeps.pl` for dependency checking instead of
    `scandeps-static.pl` ([Module::ScanDeps::Static](https://metacpan.org/pod/Module%3A%3AScanDeps%3A%3AStatic)).

    default: `scandeps-static.pl`

- --scripts-path

    Path to the file containing a list of script files.

- -t, --test-requires

    Name of the file that contains the dependencies for running tests included in your distribution if other than `test-requires`.

    default: test-requires

- --tests-path

    Path to the file containing a list of test files.

- -V, --verbose

    Verbose output.

- -v, --version

    Returns the version of this script.

- --version-from

    Name of the module that provides the package version. Defaults to the
    main module being packaged.

# BUILD SPECIFICATION FORMAT

Example:

    version: 1.7.5
    project:
      git: https://github.com/rlauer6/perl-Amazon-Credentials
      description: "AWS credentials discoverer"
      author:
        name: Rob Lauer
        mailto: rlauer6@comcast.net
    pm_module: Amazon::Credentials
    include-version: no
    dependencies:
      resolver: scandeps
      requires: requires
      test_requires: test-requires
      required_modules: no
    path:
      recurse: yes
      pm_module: src/main/perl/lib
      tests: src/main/perl/t
      exe_files: src/main/perl/bin
    exclude_files: exclude_files
    extra: extra-files
    extra-files:
      - file
      - /usr/local/share/my-project:
        - file
    provides: provides
    postamble: postamble
    resources:
      homepage: 'http://github.com/rlauer6/perl-Amazon-API'
      bugtracker:
        web: 'http://github.com/rlauer6/perl-Amazon-API/issues'
        mailto: rlauer6@comcast.net
      repository:
        url: 'git://github.com/rlauer6/perl-Amazon-API.git'
        web: 'http://github.com/rlauer6/perl-Amazon-API'
        type: 'git'

The sections are described below:

- version

    The version of of the specification format.  This should correspond
    with the version of `CPAN::Maker` that supports the format. It may be
    used in future versions to validate the specification file.

- project
    - git

        The path to a `git` project. If this is included in the buildspec
        then the bash script will clone that repo and use that repo as the
        target of the build.  If the cloned repo includes a `configure.ac`
        file root directory the script will attempt to build the repo as a
        autoconfiscated project.

            autoconf -i --force
            ./configure
            make

        If `configure.ac` is not found, the project will simply be cloned and
        it will be assumed the Perl modules and artifacts to be packaged are
        somewhere to be found in the project tree (as described in your
        buildspec file). You should make sure that you set the `path` section
        accordingly so that the utility knows were to find your Perl modules.

        _I'm actually not sure how useful this feature is. I'm guessing that
        the scenario for use might be if you have the buildspec file somewhere
        other than the repo you wish to build or you don't own or don't want
        to fork a project but want to build a CPAN distribution from it?_

    - description

        The description of the module as it will be appear in the CPAN
        repository.

    - author

        The _author_ section should contain a name and email address.

        - name

            The author's name.

        - mailto

            The author's email address.
- pm\_module

    The name of the Perl module.

- postamble

    The name of a file that contains additional `makefile` statements
    that are appended to the `Makefile` created by
    `Makefile.PL`. Typically, this will look something like:

        postamble ::

        install::
               # do something

- include-version

    If dependencies are resolved automatically, include the version
    number. To disable this set this value to 'no'.

    default: yes

- dependencies

    The _dependencies_ section, if present may contain the fully
    qualified path to a file that contains a list of dependencies. If
    the name of the file is `cpanfile`, then the file is assumed to be in
    _cpanfile_ format, otherwise the file should be a simple list of Perl
    module names optionally followed by a version number.

        Amazon::Credentials 1.15

    By default, the script will look for `scandeps-static.pl` as the
    dependency resolver, however you can override this by specifying the
    name of program that will produce a list of modules.  If you specify
    the special name _scandeps_, the scripts will use `scandeps.pl`.

    _NOTE: `scandeps-static.pl` is provided by
    [Module::ScanDeps::Static](https://metacpan.org/pod/Module%3A%3AScanDeps%3A%3AStatic) and is (at least by this author to be a
    bit superior to `scandeps.pl`._

    - recommends

        Fully qualified path to a file listing optional recommended
        dependencies. Modules listed here will appear under
        `prereqs.runtime.recommends` in the generated META files, and can be
        installed with `cpanm --with-recommends`.

        Example `recommends` file:

            Apache::ConfigParser 0
            Apache2::Request 0
            Apache2::Upload 0
            mod_perl2 0

    - requires

        Fully qualified path to a dependency list for module.

    - test\_requires

        Fully qualified path to a dependency list for tests.

    - build\_requires

        Fully qualified path to a dependency list for build.

    - resolver (optional)

        Name of a program that will provide a list of depenencies when passed
        a module name. Use the special name `scandeps` to use Perl's
        `scandeps.pl`.  When using `scandeps.pl`, the `-R` option will be
        used to prevent `scandeps.pl` from recursing. Neither
        `/usr/lib/rpm/perl.req` or `scandeps.pl` are completely
        reliable. Your methodology might be to use these to get a good start
        on a file containing dependencies and then add/subtract as required
        for your use case.

        When preparing the list of files to list as requirements in the
        `PREREQ_PM` section of the `Makefile.PL`, the script will
        automatically remove any modules that are already included with Perl.

    - required\_modules

        If the resolver should look for modules that are `required`d by your
        scripts and modules.

        default: yes

- path (optional)
    - pm\_module

        The path where the Perl module to be packaged can be found.  By
        default, the current working directory will be searched or the root of
        the search if the `recurse` value is set to 'yes'.

        default: current working directory

    - recurse (optional)

        Specifies whether to or not to look in subdirectories of the path
        specified by `pm_module` for additional modules to package.

        default: yes

    - tests (optional)

        The path where tests to be specified in the `Makefile.PL` will be
        found.

    - exe\_files

        Path where executable Perl modules will be found. Files that are to be
        included in the distribution must have executable permissions.

        Examples:

            src/main/perl/bin
            bin/

    - scripts

        Path where executable scripts (e.g. bash) will be found. Files that are to be
        included in the distribution must have executable permissions.

        Examples:

            src/main/bash/bin
            bin/
- provides (optional)

    By default the package will specify the primary module to be packaged
    and any additional modules that were found if the `recurse` option
    was set to 'yes'.

- --recommends

    Name of a file containing optional recommended dependencies. These are
    modules that enhance functionality but are not required for basic
    operation. When installed with `cpanm --with-recommends`, these will
    be installed alongside the required dependencies. If not specified,
    defaults to a file named `recommends` if present.

    Example use case: optional Apache/mod\_perl dependencies that are only
    needed in a specific deployment environment.

- resources (optional)

    Values to add to the _resources_ section of the META\_MERGE argument
    passed to [ExtUtils::MakeMaker](https://metacpan.org/pod/ExtUtils%3A%3AMakeMaker) when creating the `Makefile.PL`
    file.

    See [https://metacpan.org/pod/CPAN::Meta::Spec](https://metacpan.org/pod/CPAN::Meta::Spec) for more details.

- extra (optional)

    Name of a file that contains a list of files to be included in the
    package. These files are included in the package but not installed.

- extra-files (optional)

    List of files to be included in package.

    Example:

        extra-files:
          - ChangeLog
          - README
          - examples:
            - src/examples <= include all files in this directory

        extra-files:
          - ChangeLog
          - README
          - examples:
             - src/examples/foo.pl
             - src/examples/boo.pl

    _CAUTION: specifying a directory will include ALL of the files in
    that directory. It is a better practice list the specific files you
    want to include or provide a manifest of files in the `extra` key._

        extra: manifest

    If you include in your `extra-files` specification, a 'share'
    directory, then that directory will be installed as part of the
    distribution. The location of those files will be relative to the
    distribution's share directory and can be found like this:

        perl -MFile::ShareDir=dist_dir -e 'print dist_dir(q{My-Project});'

    The specification...

        extra-files:
          - share:   <= indicates ../auto/share/dist/My-Project
            - resources/foo.cfg

    ...would package the file `foo.cg` from your project's `resources`
    directory to the distribution's share directory. While this specification...

        extra-files:
          - share/resources: <= indicates ../auto/share/dist/My-Project/resources
            - resources/foo.cfg

    ...would package the file `foo.cfg` in the distribution's share
    directory under the `resources` directory.

    _All other files in the `extra-files` section will be added to the
    root of the tarball but will not be installed._

- scripts

    Array of script names or a path to the scripts that should be included
    in the distribution. Files should be relative to the project root.

- exe\_files

    Array of Perl script names or a path to the scripts that should be included
    in the distribution. Files should be relative to the project root.

# DEPENDENCIES

By default the script will look for dependencies in files named
`requires` and `test-requires`.  These can be created automatically
by the `bash` script (`make-cpan-dist`).

You can specify a different name for the files with the `-r` and
`-t` options.

**You must however have a file that contains the dependency list in
order to create a CPAN distribution.**

Again, if you use the `bash` script that invokes this utility or are
calling this utility with a `buildspec.yml` file, these files can be
_automatically_ created for you based on your options.  If you
provide your own `requires` or `test-requires` file, modules should
be specified as shown below unless the name of the dependency file is
[`cpanfile`](#dependencies).

    module-name version

Example:

    AWS::Signature4 1.02
    ...

# AUTHOR

Rob Lauer - <rlauer6@comcast.net>
