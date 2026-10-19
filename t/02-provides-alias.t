#!/usr/bin/env perl

use strict;
use warnings;

use Test::More;
use File::Path qw(make_path);
use File::Temp qw(tempdir);
use File::Spec;

use CPAN::Maker;

my $dir = tempdir( CLEANUP => 1 );
my $lib = File::Spec->catdir( $dir, 'lib' );
my $parent = File::Spec->catdir( $lib, 'Bedrock', 'Text' );
make_path($parent);

my $file = File::Spec->catfile( $parent, 'URLEncode.pm' );
open my $fh, '>', $file or die "cannot write fixture: $!";
print {$fh} "package Text::URLEncode;\nour \$VERSION = '1.23';\n1;\n";
close $fh;

my $maker = bless {}, 'CPAN::Maker';
my $provides_file = File::Spec->catfile( $dir, 'provides' );

$maker->create_provides( path => $lib, file => $provides_file );

# Simulate the staged merge of explicit buildspec.yml declarations.
open my $append, '>>', $provides_file or die "cannot append provides: $!";
$maker->_write_provides( $append, ['Text::URLEncode'] );
close $append;

my %provides = $maker->get_provides(
  file     => $provides_file,
  work_dir => $dir,
);

ok( exists $provides{'Text::URLEncode'}, 'explicitly declared package is provided' );
is( $provides{'Text::URLEncode'}{file}, 'lib/Bedrock/Text/URLEncode.pm',
  'package resolves to actual file rather than inferred pathname' );
ok( !exists $provides{'Bedrock::Text::URLEncode'},
  'inferred package name is not advertised if it is not declared' );

done_testing;
