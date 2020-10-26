#!/usr/bin/perl
use Data::Dumper;
use warnings;
use strict;

use File::Slurp;
my @f = read_file(\*STDIN);

my @matrix;
my $N = 1000;



for my $stage (1..2)
{
    #push @matrix, [(0)x$N] for (0..$N-1);
    for my $x (0..$N-1)
    {
        for my $y (0..$N-1)
        {
            $matrix[$x][$y] = 0;
        }
    }

    for (@f)
    {
        my ($a,$x1,$y1,$x2,$y2) = m/(toggle|turn on|turn off)\s+(\d+),(\d+).*?(\d+),(\d+)/;

        for my $x ($x1..$x2)
        {
            for my $y ($y1..$y2)
            {
                if ($a eq 'toggle')
                {
                    $matrix[$x][$y] = $stage == 1 ? ($matrix[$x][$y] + 1) % 2 : $matrix[$x][$y] + 2;
                }
                elsif ($a eq 'turn on')
                {
                    $matrix[$x][$y] = $stage == 1 ? 1 : $matrix[$x][$y] + 1;
                }
                else # off
                {
                    $matrix[$x][$y] = $matrix[$x][$y] - 1; # for stage 1 it never exceeds 1
                    $matrix[$x][$y] = 0 if $matrix[$x][$y] < 0;
                }
            }
        }
    }

    my $i = 0;
    for my $x (0..$N-1)
    {
        for my $y (0..$N-1)
        {
            $i += $matrix[$x][$y];
        }
    }

    print "stage $stage: $i\n";

}