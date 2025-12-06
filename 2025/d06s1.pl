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

my @l = read_file(\*STDIN, chomp => 1);
my @ops;
my @e;
for (@l)
{
    s/^\s+//;
    if (/\+/)
    {
        @ops = split/\s+/;
    }
    else
    {
        my @a = split/\s+/;
        my $i = 0;
        push(@{$e[$i++]}, $_) for @a;
    }
}

my $i = 0;
for my $op (@ops)
{
    $stage1 += $op eq '+' ? sum @{$e[$i]} : product @{$e[$i]};
    $i++;
}

say "Stage 1: ", $stage1;
