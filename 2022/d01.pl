#!/usr/bin/perl
use warnings;
use strict;
use Data::Dumper;
use List::Util qw/min max first sum product all any uniq head tail reduce/;
use File::Slurp;
use Algorithm::Combinatorics qw(combinations permutations variations);
use Clone qw/clone/;

my @f = read_file(\*STDIN, chomp => 1);

my @s;
my $i = 0;
for (@f)
{
    unless ($_)
    {
        $i++;
        next;
    }
    $s[$i] += $_;
}

printf "Stage 1: %s\n", max(@s);
printf "Stage 2: %s\n", sum((sort { $b <=> $a } (@s))[0..2]);