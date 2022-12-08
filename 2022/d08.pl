#!/usr/bin/perl
#use v5.36;
use warnings;
use strict;
use File::Slurp;
use Data::Dumper;
use List::Util qw/min max first sum product all any uniq head tail reduce/;
use Algorithm::Combinatorics qw(combinations permutations variations);
use Clone qw/clone/;
$" = ":"; # set separator for multidimensional hash

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
    for my $x (1..$maxx-1)
    {
        my $v = $t->{$x,$y};

        my $nv = 0;
        for my $tx (0..$x-1)     { if ($t->{$tx,$y} >= $v) { $nv++; last; }}
        for my $tx ($x+1..$maxy) { if ($t->{$tx,$y} >= $v) { $nv++; last; }}
        for my $ty (0..$y-1)     { if ($t->{$x,$ty} >= $v) { $nv++; last; }}
        for my $ty ($y+1..$maxy) { if ($t->{$x,$ty} >= $v) { $nv++; last; }}

        $stage1-- if $nv == 4;
    }
}

my $best = 0;
for my $y (1..$maxy-1)
{
    for my $x (1..$maxx-1)
    {
        my $v = $t->{$x,$y};

        my $nv = 0;
        my @sc = ();
        my $sci = 0;

        my $tx = $x-1;
        while (1)
        {
            $sc[$sci]++;
            last if $tx == 0 || $t->{$tx,$y} >= $v;
            $tx--;
        }
        $sci++;

        $tx = $x+1;
        while (1)
        {
            $sc[$sci]++;
            last if $tx == $maxx || $t->{$tx,$y} >= $v;
            $tx++;
        }
        $sci++;

        my $ty = $y-1;
        while (1)
        {
            $sc[$sci]++;
            last if $ty == 0 || $t->{$x,$ty} >= $v;
            $ty--;
        }
        $sci++;

        $ty = $y+1;
        while (1)
        {
            $sc[$sci]++;
            last if $ty == $maxy || $t->{$x,$ty} >= $v;
            $ty++;
        }

        my $mm = product @sc;
        $stage2 = $mm if $mm > $stage2;
#        print "$sc1 $sc2 $sc3 $sc4 = $mm ($stage2)\n";
    }

}

printf "Stage 1: %s\n", $stage1;
printf "Stage 2: %s\n", $stage2;
