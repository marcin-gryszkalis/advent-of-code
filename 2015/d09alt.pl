#!/usr/bin/perl
use 5.28.0;
use warnings;
use strict;
use Data::Dumper;
use List::Util qw/min max/;
use Graph::Undirected;
use Algorithm::Combinatorics qw(combinations permutations);

my $max = 0;
my $min = 1000000;

my $dist;
while (<>)
{
    chomp;
    # London to Dublin = 464
    if (/(\S+)\s+to\s+(\S+)\s+=\s+(\d+)/)
    {
        $dist->{$2}->{$1} = $dist->{$1}->{$2} = $3;
    }
}

my @cities = sort keys %$dist;
my $it = permutations(\@cities);
while (my $c = $it->next)
{
    my $sum = 0;
    for my $i (0..scalar(@cities)-2)
    {
        $sum += $dist->{$c->[$i]}->{$c->[$i+1]};
    }
    $max = $sum if $sum > $max;
    $min = $sum if $sum < $min;
}

printf "Stage 1: %d\n", $min;
printf "Stage 2: %d\n", $max;