#!/usr/bin/perl
use warnings;
use strict;
use File::Slurp;
use Data::Dumper;
use List::Util qw/min max first sum product all any uniq head tail reduce/;

my @f = read_file(\*STDIN, chomp => 1);

my $headmove = {"U" => [0,1], "D" => [0,-1], "L" => [-1,0], "R" => [1,0]};

for my $stage (1..2)
{
    my $tail = $stage == 1 ? 1 : 9;

    my @x = map { 0 } (0..$tail);
    my @y = map { 0 } (0..$tail);

    my $v;
    $v->{$x[$tail],$y[$tail]} = 1;

    for (@f)
    {
        my ($d,$c) = split/\s/;

        $x[0] += $c * $headmove->{$d}->[0];
        $y[0] += $c * $headmove->{$d}->[1];

        my $moved = 1;
        while ($moved)
        {
            $moved = 0;
            for my $i (1..$tail)
            {
                my $dist = sqrt(($y[$i]-$y[$i-1])**2 + ($x[$i]-$x[$i-1])**2);
#                printf "$d$c [$i] %d,%d - %d,%d = $dist\n", $x[$i-1], $y[$i-1], $x[$i], $y[$i];
                next if $dist < 2;

                $y[$i] += ($y[$i-1] <=> $y[$i]);
                $x[$i] += ($x[$i-1] <=> $x[$i]);
                $moved = 1;
            }

            $v->{$x[$tail],$y[$tail]} = 1;
        }
    }

    printf "Stage $stage: %d\n", scalar %$v;
}