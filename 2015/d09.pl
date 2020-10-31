#!/usr/bin/perl
use 5.28.0;
use warnings;
use strict;
use Data::Dumper;
use List::Util qw/min max/;
use Graph::Undirected;
use Algorithm::Combinatorics qw(combinations); #     # my $it = combinations(\@kvs, 2);

my $g = Graph::Undirected->new;

while (<>)
{
    chomp;
    # London to Dublin = 464
    if (/(\S+)\s+to\s+(\S+)\s+=\s+(\d+)/)
    {
        $g->add_weighted_edge($1, $2, $3);
    }
}

my @compare = (
    sub { $a = shift; $b = shift; return $a < $b },
    sub { $a = shift; $b = shift; return $a > $b }
);

my @kvs = $g->vertices;
my $vc = scalar(@kvs);

my $stage = 0;
my $best = 0;
my $visited = {};
my @path = ();
my $dist = 0;

sub tsp
{
    my $v = shift;
    my $level = shift;

    $visited->{$v} = 1;
    push(@path, $v);

    if ($level == $vc) # bottom?
    {
        if ($compare[$stage]->($dist, $best))
        {
            $best = $dist;
            printf("%d %s = BEST %d\n", $stage+1, join(" -> ", @path), $best);
        }
    }

    my @nbs = $g->neighbours($v);

    for my $n (@nbs)
    {
        next if $visited->{$n};

        my $d = $g->get_edge_weight($v,$n);
        $dist += $d;
        if ($stage == 1 || $compare[$stage]->($dist,$best)) # for longest path (stage 2) we cannot optimize
        {
            tsp($n, $level+1);
        }
        $dist -= $d;
    }

    delete $visited->{$v};
    pop(@path);
}

for my $sx (0..1)
{
    $stage = $sx;
    $best = $stage == 0 ? 1000000 : -1;
    @path = ();
    $visited = {};
    $dist = 0;

    for my $start (@kvs)
    {
        tsp($start,1);
    }

    printf "Stage %d: %d\n\n", $stage+1, $best;
}

