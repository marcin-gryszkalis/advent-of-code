#!/usr/bin/perl
use 5.28.0;
use warnings;
use strict;
use Data::Dumper;
use List::Util qw/min max/;
use Graph::Undirected;
use Algorithm::Combinatorics qw(combinations);

my $g = Graph::Undirected->new;

my @nodes;
while (<>)
{
    chomp;
    my @p = split/,/;
    push(@nodes, \@p);
    $g->add_vertex(join(" ", @p));
}

my $it = combinations(\@nodes, 2);
while (my $p = $it->next)
{
    my $n1 = $p->[0];
    my $n2 = $p->[1];

    my $l1 = join(" ", @$n1);
    my $l2 = join(" ", @$n2);

    my $dist = 0;
    for my $i (0..3)
    {
        $dist += abs($n1->[$i] - $n2->[$i])
    }

    $g->add_weighted_edge($l1, $l2, $dist) if $dist <= 3;
}

my @cc = $g->connected_components();
printf "stage 1: %d\n", scalar(@cc);

