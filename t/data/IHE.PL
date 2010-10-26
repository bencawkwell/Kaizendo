#!/usr/bin/env perl

use File::Copy;
use File::Glob;
use FindBin qw($Bin);

my $dest = $ARGV[0] || "t/data/IHE";
my $src  = "books/www.dreamsongs.com/IHE/plain";

-d $src || die "Can't access IHE test data source at'$src': $!";

-d $dest
   || mkdir($dest)
   || die "Can't create IHE test data dest at '$dest': $!";

foreach ( <$src/*> ) {
    copy($_, $dest) || die "Can't copy from '$_' to '$dest': $!";
}

print "IHE books copied to '$dest'\n";
