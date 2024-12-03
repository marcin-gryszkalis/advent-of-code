#!/usr/bin/perl
use warnings;
use strict;
use feature qw/state signatures say multidimensional/;
use File::Slurp;
use Data::Dumper;
use List::Util qw/min max first sum sum0 product all any uniq head tail reduce pairs pairmap pairkeys pairvalues zip mesh/;
use List::MoreUtils qw/firstidx frequency mode pairwise slide minmax minmaxstr/;
use POSIX qw/ceil floor/;
use Clone qw/clone/;
$; = ',';

$_ = join("", read_file(\*STDIN, chomp => 1));

say "Stage 1: ", sum pairmap { $a * $b } m/mul\((\d+),(\d+)\)/g;
s/don't\(\).*?(do\(\)|$)//g;
say "Stage 2: ", sum pairmap { $a * $b } m/mul\((\d+),(\d+)\)/g;
