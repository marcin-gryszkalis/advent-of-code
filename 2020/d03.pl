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

my @delta = qw/11 31 51 71 12/;

my $m;

my $c;
my $r = 0;
for (@f)
{
    my @a = split//;
    $m->[$r++] = \@a;
}

my $w = scalar(@{$m->[0]});
my $h = scalar(@$m);

my $s1 = 0;
my $s2 = 1;
for my $d (@delta)
{
    my ($dc, $dr) = split//, $d;

    $r = 0;
    $c = 0;
    my $x = 0;
    while ($r < $h)
    {
        $x++ if $m->[$r]->[$c] eq '#';
        $c = ($c + $dc) % $w;
        $r += $dr;
    }

    $s1 = $x if $d eq '31'; # stage 1 case
    $s2 *= $x;
}

printf "stage 1: %d\n", $s1;
printf "stage 2: %d\n", $s2;