#!/usr/bin/env perl

use strict;
use warnings;
use Test::More tests=>1;
use autodie;

# Move the files around
system("ce_mvFile.sh test.sqlite filerepo/1/1.txt filerepo/2/");
system("ce_mvFile.sh test.sqlite filerepo/2/2.txt filerepo/3/");
system("ce_mvFile.sh test.sqlite filerepo/3/3.txt filerepo/1/");
#system("md5sum test.sqlite");

my $md5sum=`sqlite3 test.sqlite '.dump' | grep -v "INSERT INTO OPERATION" | md5sum
`;
$md5sum=~s/\s+.*//;
chomp($md5sum);
is $md5sum, "d1bf1ceb40eaf3b3059b2746cdfabf0b", "moved three files"

