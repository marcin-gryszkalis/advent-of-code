#!/usr/bin/perl
use warnings;
use strict;
use Data::Dumper;
use List::Util qw/min max first sum product/;
use List::MoreUtils qw(uniq);
use File::Slurp;
use Algorithm::Combinatorics qw(combinations permutations);

my @f = read_file(\*STDIN);
@f = map { chomp; $_ } @f;
my $inpside = length($f[0]);

my $OFF = 2000;

my $side = 2*$OFF + $inpside;

my $m;
push @$m, [('.')x$side] for (0..$side-1);

for my $r (0..$inpside-1)
{
    my @a = split//,$f[$r];
    for my $c (0..$inpside-1)
    {
        $m->[$r+$OFF]->[$c+$OFF] = $a[$c];
    }
}

my $vx = int($side/2);
my $vy = $vx;
my $d = 0; # N E S W
my @dx = qw/0 1 0 -1/;
my @dy = qw/-1 0 1 0/;

my $infected = 0;

for my $b (1..10_000)
{
    # If the current node is infected, it turns to its right. Otherwise, it turns to its left. (Turning is done in-place; the current node does not change.)
    # If the current node is clean, it becomes infected. Otherwise, it becomes cleaned. (This is done after the node is considered for the purposes of changing direction.)
    if ($m->[$vy]->[$vx] eq '#')
    {
        $d = ($d+1) % 4;
        $m->[$vy]->[$vx] = '.';
    }
    else
    {
        $d = ($d+3) % 4;
        $m->[$vy]->[$vx] = '#';
        $infected++;
    }
    $vx += $dx[$d];
    $vy += $dy[$d];
}

print "stage 1: $infected\n";