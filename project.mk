#-*- mode: gnumakefile; -*-

CONSTANTS = \
    lib/CPAN/Maker/Constants.pm

UTILS = \
   lib/CPAN/Maker/Utils.pm

$(UTILS): $(CONSTANTS)

ROLES = \
   lib/CPAN/Maker/Role/FileUtils.pm \
   lib/CPAN/Maker/Role/ModuleUtils.pm

$(ROLES): $(UTILS)

lib/CPAN/Maker.pm: $(ROLES)

lib/File/Process.pm: lib/File/Process/Utils.pm
