#!/usr/bin/env perl

use strict;
use warnings;
use Test::More tests=>1;
use autodie;

system("ce_createDb.sh test.sqlite");
my $md5sum = `md5sum < test.sqlite`;
$md5sum=~s/\s+.*//;
chomp($md5sum);

is $md5sum, '42ac8347c8037f0509e79acc5503927f', "fresh database md5sum"

