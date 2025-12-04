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

my @l = read_file(\*STDIN, chomp => 1);

my $i = 50;
for (@l)
{
    /([LR])(\d+)/;
    my $sign = $1 eq 'R' ? 1 : -1;
    my $v = $2;

    for (1..$v)
    {
        $i = ($i + $sign + 100) % 100;
        $stage2++ if $i == 0;
    }
    $stage1++ if $i == 0;
}

say "Stage 1: ", $stage1;
say "Stage 2: ", $stage2;
