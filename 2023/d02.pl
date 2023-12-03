#!/usr/bin/perl
use warnings;
use strict;
use feature qw/state signatures say multidimensional/;
use File::Slurp;
use Data::Dumper;
use List::Util qw/min max first sum product all any uniq head tail reduce/;
use Algorithm::Combinatorics qw(combinations permutations variations);
use Clone qw/clone/;
$; = ',';

my @f = read_file(\*STDIN, chomp => 1);

my $stage1 = 0;
my $stage2 = 0;

my %s1limit = qw/red 12 green 13 blue 14/;

for (@f)
{
    my ($id, $r) = m/^Game (\d+): (.*)/g;
    my %max = qw/red 0 green 0 blue 0/;

    my $bad = 0;
    for my $x ($r =~ m/(\S.*?(;|$))/g)
    {
        for my $k ($x =~ m/(\d+ \D+)/g)
        {
            my ($v, $col) = ($k =~ m/(\d+) ([a-z]+)/g);

            $bad = 1 if $v > $s1limit{$col};
            $max{$col} = max($v, $max{$col});
        }
    }

    $stage1 += $id unless $bad;
    $stage2 += product(values %max);
}

printf "Stage 1: %s\n", $stage1;
printf "Stage 2: %s\n", $stage2;
