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

my $divisor = 25; # shoot

for my $stage (1..2)
{
    my @houses = ();
    for my $elf (1..$target/$divisor)
    {
        my $h = $elf;
        my $c = 0;
        while (1)
        {
            $houses[$h] += $elf * (10 + $stage - 1);
            last if $h > $target/$divisor;
            $h += $elf;

            last if $stage == 2 && $c >= $stage2_presents;
            $c++;

        }
    }

    for my $h (1..$target/$divisor)
    {
        if ($houses[$h] > $target)
        {
            printf "stage %d: %d - %d presents\n", $stage, $h, $houses[$h];
            last;
        }
    }
}
