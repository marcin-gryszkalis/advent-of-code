#!/usr/bin/perl
use Data::Dumper;
use warnings;
use strict;

use File::Slurp;
my @f = read_file(\*STDIN);

my @matrix;
my $N = 1000;


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

    if ($a eq 'toggle')
    {
        for my $x ($x1..$x2)
        {
            for my $y ($y1..$y2)
            {
                $matrix[$x][$y] = ($matrix[$x][$y] + 1) % 2;
            }
        }
    }
    elsif ($a eq 'turn on')
    {
        for my $x ($x1..$x2)
        {
            for my $y ($y1..$y2)
            {
                $matrix[$x][$y] = 1;
            }
        }
    }
    else # off
    {
        for my $x ($x1..$x2)
        {
            for my $y ($y1..$y2)
            {
                $matrix[$x][$y] = 0;
            }
        }

    }
}


my $i = 0;
for my $x (0..$N-1)
{
    for my $y (0..$N-1)
    {
        $i++ if $matrix[$x][$y];
    }
}

print "stage 1: $i\n";


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

    if ($a eq 'toggle')
    {
        for my $x ($x1..$x2)
        {
            for my $y ($y1..$y2)
            {
                $matrix[$x][$y] += 2;
            }
        }
    }
    elsif ($a eq 'turn on')
    {
        for my $x ($x1..$x2)
        {
            for my $y ($y1..$y2)
            {
                $matrix[$x][$y]++;
            }
        }
    }
    else # off
    {
        for my $x ($x1..$x2)
        {
            for my $y ($y1..$y2)
            {
                $matrix[$x][$y]-- if $matrix[$x][$y] > 0;
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

print "stage 2: $i\n";

