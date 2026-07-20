# ./lib/CPAN/Maker.pm.in
./lib/CPAN/Maker.pm: \
    ./lib/CPAN/Maker/Constants.pm \
    ./lib/CPAN/Maker/Role/FileUtils.pm \
    ./lib/CPAN/Maker/Role/ModuleUtils.pm \
    ./lib/CPAN/Maker/Utils.pm

# ./lib/CPAN/Maker/Role/FileUtils.pm.in
./lib/CPAN/Maker/Role/FileUtils.pm: \
    ./lib/CPAN/Maker/Utils.pm

# ./lib/CPAN/Maker/Utils.pm.in
./lib/CPAN/Maker/Utils.pm: \
    ./lib/CPAN/Maker/Constants.pm

