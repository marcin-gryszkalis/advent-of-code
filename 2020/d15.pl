#!/usr/bin/perl
use warnings;
use strict;
use Data::Dumper;
use List::Util qw/min max first sum product/;
use List::MoreUtils qw(uniq);
use File::Slurp;
use Algorithm::Combinatorics qw(combinations permutations);
use Clone qw/clone/;

#my @in = qw/0 3 6/;
my @in = qw/0 13 1 8 6 15/;

my $stage1 = 0;
my $stage2 = 0;

my $r = 1;
my %h = map { $_ => $r++ } @in;

my $p = $in[$#in]; # num spoken in  prev round
while (1)
{
    my $d = defined $h{$p} ? ($r - 1 - $h{$p}) : 0;
    $h{$p} = $r-1;
    $p = $d;

    $stage1 = $d if $r == 2020;
    $stage2 = $d if $r == 30_000_000;
    last if $stage1 && $stage2;

    $r++;
}

print "stage 1: $stage1\n";
print "stage 2: $stage2\n";