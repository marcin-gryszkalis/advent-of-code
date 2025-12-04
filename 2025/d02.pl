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

my $stage1 = 0;
my $stage2 = 0;

my @l = split(/,/, read_file(\*STDIN, chomp => 1));

for (@l)
{
    my ($a,$b) = split/-/;
    for my $d ($a..$b)
    {
        $stage1 += $d if $d =~ /^(.*)\1$/;
        $stage2 += $d if $d =~ /^(.+)\1+$/;
    }
}

say "Stage 1: ", $stage1;
say "Stage 2: ", $stage2;
