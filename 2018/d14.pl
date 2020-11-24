#!/usr/bin/perl
use warnings;
use strict;
use Data::Dumper;
use List::Util qw/min max first sum product/;
use List::MoreUtils qw(uniq);
use File::Slurp;
use Algorithm::Combinatorics qw(combinations permutations);

my $N = 846021;
my $L = length $N;

my @t = (3, 7);

my $i = 0;
my $j = 1;

my $stage1 = 0;
my $stage2 = 0;
L: while (1)
{
    my $s = $t[$i] + $t[$j];
    push(@t, split(//, $s));
    $i = ($i + 1 + $t[$i]) % scalar(@t);
    $j = ($j + 1 + $t[$j]) % scalar(@t);

    if ($stage1 == 0 && scalar(@t) > $N + 9)
    {
        $stage1 = join("", (@t[$N..$N+9]));
    }

    my $k = scalar(@t)-$L;
    for (1..length($s))
    {
        if (join("", (@t[$k..$k+$L-1])) eq $N)
        {
            $stage2 = $k;
            last L;
        }
        $k--;
    }
}

printf "stage 1: %s\n", $stage1;
printf "stage 2: %d\n", $stage2;
