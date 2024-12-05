#!/usr/bin/perl
use warnings;
use strict;
use feature qw/state signatures say multidimensional/;
use File::Slurp;
use Data::Dumper;
use List::Util qw/min max first sum sum0 product all any uniq head tail reduce pairs pairmap pairgrep pairfirst pairkeys pairvalues zip mesh/;
use List::MoreUtils qw/firstidx frequency mode pairwise slide minmax minmaxstr/;
# use Algorithm::Combinatorics qw/combinations permutations variations/;
use POSIX qw/ceil floor/;
use Clone qw/clone/;
$; = ',';

my @f = read_file(\*STDIN, chomp => 1);

my $stage1 = 0;
my $stage2 = 0;

my $rules;
my @updates;
for (@f)
{
    $rules->{$1,$2} = 1 if /(\d+)\|(\d+)/;
    push(@updates, $_) if /,/;
}

for my $u (@updates)
{
    my @pages = split /,/, $u;
    my @fixed = sort { exists $rules->{$a,$b} ? -1 : 1 } @pages;
    unless (pairfirst { $a != $b } mesh \@pages, \@fixed)
    {
        $stage1 += $pages[$#pages/2];
    }
    else
    {
        $stage2 += $fixed[$#fixed/2];
    }
}

say "Stage 1: ", $stage1;
say "Stage 2: ", $stage2;
