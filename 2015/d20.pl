#!/usr/bin/perl
use warnings;
use strict;
use Data::Dumper;
use List::Util qw/min max/;
use List::MoreUtils qw(uniq);
use File::Slurp;
use Algorithm::Combinatorics qw(combinations permutations);


my $target = 34_000_000;
my $stage2_presents = 50;

my $house = 700000;  # 786240
my $sum = 0;
while (1)
{
    my $i = 1;
    $sum = 0;
    while ($i <= sqrt($house))
    {
        if ($house % $i == 0)
        {
            $sum += $i;
            my $d2 = $house / $i;
            $sum += $d2 if $d2 != $i;
        }
        $i++;
    }

    $sum *= 10;
#    printf "%4d %10d\n", $house, $sum;

    last if $sum >= $target;
    $house++;
}

printf "stage 1: %d - %d presents\n", $house, $sum;


$house = 786240; # 831600
while (1)
{
    my $i = 1;
    $sum = 0;
    while ($i <= sqrt($house))
    {
        if ($house % $i == 0)
        {
            $sum += $i if $i * $stage2_presents >= $house;
            my $d2 = $house / $i;
            $sum += $d2 if $d2 != $i && $d2 * $stage2_presents >= $house;
        }
        $i++;
    }

    $sum *= 11;
#    printf "%4d %10d\n", $house, $sum;

    last if $sum >= $target;
    $house++;
}

printf "stage 2: %d - %d presents\n", $house, $sum;
