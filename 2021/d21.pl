#!/usr/bin/perl
use warnings;
use strict;
use Data::Dumper;
use List::Util qw/min max first sum product all any uniq head tail reduce/;
use List::MoreUtils qw/pairwise/;
use File::Slurp;
use Algorithm::Combinatorics qw(combinations permutations variations variations_with_repetition);
use Clone qw/clone/;

my $target = 21;

my $p1 = 7;
my $p2 = 10;

# test values:
# $p1 = 4;
# $p2 = 8;

my $d = 1;
my @s = (0,0);
my @p = ($p1-1, $p2-1);
T: while (1)
{
    for my $i (0..1)
    {
        $p[$i] = ($p[$i] + 3*$d + 3) % 10;
        $d += 3;
        $s[$i] += ($p[$i] + 1);
        last T if $s[$i] >= 1000;
    }
}

printf "Stage 1: %s\n", min(@s) * ($d-1);

# number of moves (combinations) for given sum
my %xu = (
    3 => 1,
    4 => 3,
    5 => 6,
    6 => 7,
    7 => 6,
    8 => 3,
    9 => 1,
    );

my %cache;

my @w = (0,0);

sub d
{
    my $l = shift; # level
    my $p = $l % 2 ? 0 : 1; # player

    my $m = shift; # sum of 3 trows (move)
    my $u = shift; # universes so far on the path

    my $s = shift; # scores so far
    my $q = shift; # positions
    my $x = shift; # path as string - only for debugging

    my $cid = "$p $m ".join(" ", @$s)." ".join(" ", @$q);
    return @{$cache{$cid}} if exists $cache{$cid};

    if ($l > 0)
    {
            $x->[$p] .= $m;
            $q->[$p] = ($q->[$p] + $m) % 10;
            $s->[$p] += ($q->[$p] + 1);
            if ($s->[$p] >= $target)
            {
                return $p == 0 ? ($u, 0) : (0, $u);
            }
    }

    my @wa = (0, 0);
    for my $i (3..9)
    {
        my @a = d($l+1, $i, $xu{$i}, clone($s), clone($q), clone($x));
        @wa = pairwise { $a + $b } @wa, @a;
    }

    $cache{$cid} = \@wa;

    @wa = map { $_ * $u } @wa;

    return @wa;
}

@w = d(0, 1, 1 , [0, 0], [$p1-1, $p2-1], ["", ""]);

printf "Stage 2: %s\n", max(@w);
