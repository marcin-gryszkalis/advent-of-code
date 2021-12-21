#!/usr/bin/perl
use warnings;
use strict;
use Data::Dumper;
use List::Util qw/min max first sum product all any uniq head tail reduce/;
use File::Slurp;
use Algorithm::Combinatorics qw(combinations permutations variations variations_with_repetition);
use Clone qw/clone/;

my $target = 21;
# $target = 11;
 
my $p1 = 7;
my $p2 = 10;

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

my %xu = (
    3 => 1,
    4 => 3,
    5 => 6,
    6 => 7,
    7 => 6,
    8 => 3,
    9 => 1,
    );


my @w = (0,0);

sub d
{
    my $l = shift; # level
    my $p = $l % 2 ? 0 : 1; # player

    my $m = shift; # sum of 3 trows (move)
    my $u = shift; # universes so far on the path
    
    my $s = shift; # scores so far
    my $q = shift; # positions
    my $x = shift; # path as string

    if ($l > 0)
    {
            $x->[$p] .= $m;
            $q->[$p] = ($q->[$p] + $m) % 10;
            $s->[$p] += ($q->[$p] + 1);
            if ($s->[$p] >= $target)
            {
                $w[$p] += $u;
                print "p".($p+1)." won (score=$s->[$p]) at level($l) with u=$u (total $w[$p]) x1=$x->[0] x2=$x->[1]\n";
                return;
            }
    }

#   print "p=$p l=$l m=$m u=$u q: $q->[0] $q->[1] s: $s->[0] $s->[1] \n";

   for my $i (3..9)
   {
       d($l+1, $i, $u * $xu{$i}, clone($s), clone($q), clone($x));
   }
}

d(0, 1, 1 , [0, 0], [$p1, $p2], ["", ""]);
print "$w[0]\n$w[1]\n";

printf "Stage 2: %s\n", max(@w);
