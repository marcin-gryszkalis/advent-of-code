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

while (<>)
{
    next unless m/Disc #(\d+) has (\d+) positions; at time=0, it is at position (\d+)./;
    $discs->{$1}->{positions} = $2;
    $discs->{$1}->{start} = $3;
}

my $N = max(keys %$discs);

for my $stage (1..2)
{
    my $t = 0;
    LOOP: while (1)
    {
        $t++;

        for my $d (1..$N)
        {
            next LOOP if ($discs->{$d}->{start} + $t + $d) % $discs->{$d}->{positions} > 0;
        }

        print "Stage $stage: $t\n";
        last;
    }

    # stage 2 adds one disc
    $N++;
    $discs->{$N}->{positions} = 11;
    $discs->{$N}->{start} = 0;
}