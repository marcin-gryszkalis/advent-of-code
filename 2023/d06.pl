#!/usr/bin/perl
use warnings;
use strict;
use feature qw/state signatures say multidimensional/;
use File::Slurp;
use Data::Dumper;
use List::Util qw/min max first sum product all any uniq head tail reduce zip/;
use POSIX qw/ceil floor/;
use Algorithm::Combinatorics qw(combinations permutations variations);
use Clone qw/clone/;
$; = ',';

my @f = read_file(\*STDIN, chomp => 1);

my @times = ($f[0] =~ /(\d+)/g);
my @dists = ($f[1] =~ /(\d+)/g);

my $s2t = ($f[0] =~ s/\D+//gr);
my $s2d = ($f[1] =~ s/\D+//gr);

my $stage1 = 1;
my $stage2 = 0;
for my $t (@times)
{
    my $d = shift @dists;

    my $s = 0;
    for my $p (0..$t)
    {
        $s++ if ($t - $p) * $p > $d;
    }

    $stage1 *= $s;
}

for my $p (0..$s2t)
{
    $stage2++ if ($s2t - $p) * $p > $s2d;
}

# alt O(1) - just solve it :)
my $delta = $s2t ** 2 - 4 * (-1) * (-$s2d);
my $x1 = (-$s2t - sqrt($delta)) / 2 * (-1);
my $x2 = (-$s2t + sqrt($delta)) / 2 * (-1);
$stage2 = floor($x1) - ceil($x2) + 1;

printf "Stage 1: %s\n", $stage1;
printf "Stage 2: %s\n", $stage2;