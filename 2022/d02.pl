#!/usr/bin/perl
use warnings;
use strict;
use Data::Dumper;
use List::Util qw/min max first sum product all any uniq head tail reduce/;
use File::Slurp;
use Algorithm::Combinatorics qw(combinations permutations variations);
use Clone qw/clone/;

my @f = read_file(\*STDIN, chomp => 1);

for my $stage (1..2)
{
    my $s = 0;
    for (@f)
    {
        my ($a,$b) = split/ /;
        $a = ord($a) - ord('A');
        $b = ord($b) - ord('X');

        # reply to $a, to have outcome from $b
        # b beats a if it's 1 step further, loses if it's 2 steps further
        $b = ($a + $b + 2) % 3 if $stage == 2;

        $s += $b+1;
        $s += 3 if $a == $b;
        $s += 6 if ($a+1) % 3 == $b;
    }

    printf "Stage %d: %s\n", $stage, $s;
}