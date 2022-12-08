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

my $x = 0;
my $y = 0;
my $t;

for (@f)
{
    $x = 0;
    for my $v (split//)
    {
        $t->{$x++,$y} = $v;
    }
    $y++;
}
my $h = $y;
my $w = length($f[0]);
my $maxy = $h - 1;
my $maxx = $w - 1;


$stage1 = ($maxx+1)*($maxy+1);
for my $y (1..$maxy-1)
{
    S: for my $x (1..$maxx-1)
    {
        my $v = $t->{$x,$y};

        my $nv = 0;
        for my $tx (0..$x-1)
        {
            if ($t->{$tx,$y} >= $v)
            {
                $nv++;
                last;
            }
        }
        for my $tx ($x+1..$maxy)
        {
            if ($t->{$tx,$y} >= $v)
            {
                $nv++;
                last;
            }
        }

        for my $ty (0..$y-1)
        {
            if ($t->{$x,$ty} >= $v)
            {
                $nv++;
                last;
            }
        }

        for my $ty ($y+1..$maxy)
        {
            if ($t->{$x,$ty} >= $v)
            {
                $nv++;
                last;
            }
        }

        $stage1-- if $nv == 4;
    }

}


my $best = 0;
for my $y (1..$maxy-1)
{
    S: for my $x (1..$maxx-1)
    {
        my $v = $t->{$x,$y};

        my $nv = 0;

        my $tx = $x-1;
        my $sc1 = 0;
        while (1)
        {
            $sc1++;
            last if ($t->{$tx,$y} >= $v);
            last if $tx == 0;
            $tx--;
        }

        $tx = $x+1;
        my $sc2 = 0;
        while (1)
        {
            $sc2++;
            last if ($t->{$tx,$y} >= $v);
            last if $tx == $maxx;
            $tx++;
        }

        my $ty = $y-1;
        my $sc3 = 0;
        while (1)
        {
            $sc3++;
            last if ($t->{$x,$ty} >= $v);
            last if $ty == 0;
            $ty--;
        }

        $ty = $y+1;
        my $sc4 = 0;
        while (1)
        {
            $sc4++;
            last if ($t->{$x,$ty} >= $v);
            last if $ty == $maxy;
            $ty++;
        }

        my $mm = $sc1*$sc2*$sc3*$sc4;
        if ($mm > $best)
        {
            $best = $mm;

        }
    }

}
printf "Stage 1: %s\n", $stage1;
printf "Stage 2: %s\n", $best;
