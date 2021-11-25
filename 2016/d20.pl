#!/usr/bin/perl
use warnings;
use strict;
use Data::Dumper;
use List::Util qw/min max first sum product all any/;
use List::MoreUtils qw(uniq);
use File::Slurp;
use Algorithm::Combinatorics qw(combinations permutations variations);
use Clone qw/clone/;

my $ranges;
while (<>)
{
    chomp;
    my @a = split/-/;
    $ranges->{$a[0]} = $a[1];
}

my $stage1 = -1;
my $stage2 = 0;

my $r = 0;
for my $l (sort { $a <=> $b } keys %$ranges)
{
    print "$l - $ranges->{$l}\n";
    if ($l > $r+1)
    {
        $stage1 = $r+1 if $stage1 == -1; # only first
        $stage2 += ($l - $r - 1);
    }
    $r = max($ranges->{$l}, $r);
}

printf "Stage 1: %d\n", $stage1;
printf "Stage 2: %d\n", $stage2;