#!/usr/bin/perl
use warnings;
use strict;
use feature qw/state signatures say multidimensional/;
use File::Slurp;
use Data::Dumper;
use List::Util qw/min max first sum sum0 product all any uniq head tail reduce pairs pairkeys pairvalues zip mesh/;
use List::MoreUtils qw/firstidx frequency mode pairwise slide minmax minmaxstr/;
use Algorithm::Combinatorics qw/combinations permutations variations/;
use POSIX qw/ceil floor/;
use Clone qw/clone/;
$; = ',';

my @l = split /\s+/, read_file(\*STDIN, chomp => 1);

my @a = sort { $a <=> $b } pairkeys @l;
my @b = sort { $a <=> $b } pairvalues @l;
my %h = frequency @b;

say "Stage 1: ", sum pairwise { abs($a - $b) } @a, @b;
say "Stage 2: ", sum map { $_ * ($h{$_} // 0) } @a;
