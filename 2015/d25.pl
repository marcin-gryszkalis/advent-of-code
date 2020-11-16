#!/usr/bin/perl
use warnings;
use strict;
use Data::Dumper;
use List::Util qw/min max first sum product/;
use List::MoreUtils qw(uniq);
use File::Slurp;
use Algorithm::Combinatorics qw(combinations permutations);

my $xrow = 2981;
my $xcol = 3075;

my $sr = 1; # starting row for diagonal
my $r = 1;
my $c = 1;

my $v = 20151125;

my $k1 = 252533;
my $k2 = 33554393;

my $d = 0;
while (1)
{
    printf "%10d: %04d x %04d = %10d\n", $d, $c, $r, $v if $d % 1000000 == 0;
    $d++;

    last if ($r == $xrow && $c == $xcol);

    $v = $v * $k1 % $k2;

    $c++;
    $r--;
    if ($r == 0)
    {
        $c = 1;
        $sr++;
        $r = $sr;
    }

}

print "stage 1: $v\n";