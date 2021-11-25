#!/usr/bin/perl
use warnings;
use strict;
use Data::Dumper;
use List::Util qw/min max first sum product all any/;
use List::MoreUtils qw(uniq);
use File::Slurp;
use Algorithm::Combinatorics qw(combinations permutations variations);
use Clone qw/clone/;

my $discs;

# Disc #1 has 13 positions; at time=0, it is at position 10.
while (<>)
{
    next unless m/Disc #(\d+) has (\d+) positions; at time=0, it is at position (\d+)./;
    $discs->{$1}->{positions} = $2;
    $discs->{$1}->{start} = $3;
}

my $N = max(keys %$discs);

my $t = 0;
LOOP: while (1)
{
    $t++;

    for my $d (1..$N)
    {
        next LOOP if ($discs->{$d}->{start} + $t + $d) % $discs->{$d}->{positions} > 0;
    }

    print "Stage 1: $t\n";
    exit;
}