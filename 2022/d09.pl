#!/usr/bin/perl
#use v5.36;
use warnings;
use strict;
use File::Slurp;
use Data::Dumper;
use List::Util qw/min max first sum product all any uniq head tail reduce/;
use Algorithm::Combinatorics qw(combinations permutations variations);
use Clone qw/clone/;

my @f = read_file(\*STDIN, chomp => 1);

my $stage1 = 0;
my $stage2 = 0;

my $shx = 100;
my $shy = 100;

my @x;
my @y;

my $tail = 9;
for my $i (0..$tail)
{
    $x[$i] = $shx;
    $y[$i] = $shy;
}

my $v;

for (@f)
{
    my ($d,$c) = split/\s/;

    if ($d eq 'R') { $x[0] += $c; }
    if ($d eq 'L') { $x[0] -= $c; }
    if ($d eq 'U') { $y[0] -= $c; }
    if ($d eq 'D') { $y[0] += $c; }

    my $moved = 1;
    L: while (1)
    {
        $v->{$x[$tail],$y[$tail]} = 1;

        $moved = 0;
        for my $i (1..$tail)
        {
            my $dist = sqrt(($y[$i]-$y[$i-1])**2 + ($x[$i]-$x[$i-1])**2);
#            printf "%d,%d - %d,%d = $dist\n", $x[$i-1],$y[$i-1],$x[$i],$y[$i];
            next if $dist < 2;

            $y[$i] += ($y[$i-1] <=> $y[$i]);
            $x[$i] += ($x[$i-1] <=> $x[$i]);
            $moved = 1;
        }

        last unless $moved;
    }
}

$stage1 = scalar keys %$v;
printf "Stage 1: %s\n", $stage1;
printf "Stage 2: %s\n", $stage2;