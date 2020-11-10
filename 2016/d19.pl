#!/usr/bin/perl
use warnings;
use strict;
use Data::Dumper;
use List::Util qw/min max first sum/;
use List::MoreUtils qw(uniq);
use File::Slurp;
use Algorithm::Combinatorics qw(combinations permutations);

my $elvescnt = 3014603;

# O(1) https://www.youtube.com/watch?v=uCsD3ZGzMgE
printf "stage 1 (quick): %d\n", (($elvescnt ^ (1 << int(log($elvescnt)/log(2)))) << 1) + 1;

# naive solution with scanning, O(n^2) but acceptable because of ordering
my @e;

my $elvesleft = $elvescnt;
@e = (1) x $elvescnt;

my $i = 0;
my $best = 0;
while (1)
{
    my $sl = 0;
    my $vx = 0;

    my $v = 0;
    if ($e[$i] > 0)
    {
        # victim search
        $v = ($i + 1) % $elvescnt;
        while ($e[$v] == 0)
        {
            $v = ($v + 1) % $elvescnt;
            $sl++;
        }

        $e[$i] += $e[$v];
        $e[$v] = 0;

        $elvesleft--;
        last if $elvesleft == 1;

        if ($e[$i] > $best)
        {
            $best = $e[$i];
        }
    }

    my $n = ($v + 1) % $elvescnt;
    while ($e[$n] == 0)
    {
        $n = ($n + 1) % $elvescnt;
    }
    $i = $n;
}

printf "stage 1 (slow!): %d\n", $i+1; # counted from 1

