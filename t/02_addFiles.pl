#!/usr/bin/env perl

use strict;
use warnings;
use Test::More tests=>1;
use autodie;

system("mkdir -pv ./filerepo/{1,2,3}/");

for my $i(1..3){
  my $newfile="filerepo/$i/$i.txt";
  open(my $fh, ">", $newfile);
  print $fh $i."\n";
  close $fh;

  system("ce_addFile.sh test.sqlite $newfile");
}

my $md5sum=`sqlite3 test.sqlite '.dump' | grep -v "INSERT INTO OPERATION" | md5sum
`;
$md5sum=~s/\s+.*//;
chomp($md5sum);
is $md5sum, "5b9a8c2bfee95d9bb81ea917f6bc44b7", "added three files"

