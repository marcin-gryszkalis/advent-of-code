#!/usr/bin/perl
use warnings;
use strict;
use Data::Dumper;
use List::Util qw/min max first sum product all any uniq head tail/;
use File::Slurp;
use Algorithm::Combinatorics qw(combinations permutations variations);
use Clone qw/clone/;
use Graph::Directed;

my @f = map { [split//] } read_file(\*STDIN, chomp => 1);

my $g = Graph::Directed->new;

my $wy = scalar(@f);
my $wx = scalar(@{$f[0]});

my $maxy = 5 * $wy - 1;
my $maxx = 5 * $wx - 1;

for my $y (0..$maxy)
{
    for my $x (0..$maxx)
    {
        my $e = $f[$y % $wy]->[$x % $wx];
        my $ae = (($e - 1) + int($x / $wx) + int($y / $wy)) % 9 + 1;

        $g->add_weighted_edge(($x-1).$;.$y, "$x$;$y", $ae) if $x > 0;
        $g->add_weighted_edge($x.$;.($y-1), "$x$;$y", $ae) if $y > 0;
        $g->add_weighted_edge(($x+1).$;.$y, "$x$;$y", $ae) if $x < $maxx;
        $g->add_weighted_edge($x.$;.($y+1), "$x$;$y", $ae) if $y < $maxy;
    }
}

print "vertices: ".scalar($g->vertices)."\n";
print "edges: ".scalar($g->edges)."\n";

my @p1 = $g->SP_Dijkstra("0$;0", ($wx-1).$;.($wy-1));
my @p2 = $g->SP_Dijkstra("0$;0", "$maxx$;$maxy");

printf "Stage 1: %s\n", sum(map { $g->get_edge_weight($p1[$_], $p1[$_+1]) } (0..$#p1-1));
printf "Stage 2: %s\n", sum(map { $g->get_edge_weight($p2[$_], $p2[$_+1]) } (0..$#p2-1));
