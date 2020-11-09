#!/usr/bin/perl
use warnings;
use strict;
use Data::Dumper;
use List::Util qw/min max first/;
use List::MoreUtils qw(uniq);
use File::Slurp;
use Algorithm::Combinatorics qw(combinations permutations);

use Graph::Undirected;


my $g = Graph::Undirected->new;

while (<>)
{
    chomp;
    # 4 <-> 2, 3, 6
    if (/(\d+)\s+\<-\>\s+(.*)/)
    {
        my $l = $1;
        my $r = $2;
        for my $d (split(/,\s*/, $r))
        {
            $g->add_weighted_edge($l, $d, 0);
        }
    }
}

my @reach = $g->all_reachable(0);
printf "stage 1: %d\n", scalar(@reach)+1;

my @cc = $g->connected_components();
printf "stage 1: %d\n", scalar(@cc);