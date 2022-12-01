#!/usr/bin/perl
use warnings;
use strict;
use Data::Dumper;
use List::Util qw/min max first sum product all any uniq head tail reduce/;
use File::Slurp;
use Algorithm::Combinatorics qw(combinations permutations variations);
use Clone qw/clone/;

my @f = read_file(\*STDIN, chomp => 1);

my $stage1 = 0;
my $stage2 = 0;

my @e;
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

$stage1 = max(@s);
$stage2 = sum((sort { $b <=> $a } (@s))[0..2]);

printf "Stage 1: %s\n", $stage1;
printf "Stage 2: %s\n", $stage2;