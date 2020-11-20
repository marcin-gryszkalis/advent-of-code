#!/usr/bin/perl
use warnings;
use strict;
use Data::Dumper;
use List::Util qw/min max first sum product/;
use List::MoreUtils qw(uniq);
use File::Slurp;
use Algorithm::Combinatorics qw(combinations permutations);

my $gpu;
my $pi = 0;
while (<>)
{
    chomp;

    my $h;
    s/[^\d-]+/ /g;
    s/^\s+//;
    my @a = split/\s+/;
    my $i = 0;
    for my $e (qw/p v a/)
    {
        for my $ax (qw/x y z/)
        {
            $h->{$e}->{$ax} = $a[$i++];
        }
    }

    $gpu->{$pi++} = $h;
}

while (1)
{
    my $best_pk = -1;
    my $best = 1_000_000_000;
    for my $pk (keys %$gpu)
    {
        my $p = $gpu->{$pk};

        my $dist = 0;
        for my $ax (qw/x y z/)
        {
            $p->{v}->{$ax} += $p->{a}->{$ax};
            $p->{p}->{$ax} += $p->{v}->{$ax};
            $dist += abs($p->{p}->{$ax});
        }
        if ($dist < $best)
        {
            $best = $dist;
            $best_pk = $pk;
        }
    }

    print "$best_pk = $best\n";
}