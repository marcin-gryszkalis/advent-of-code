#!/usr/bin/perl
use warnings;
use strict;
use File::Slurp;
use Data::Dumper;
use List::Util qw/min max first sum product all any uniq head tail reduce/;
use Graph::Directed;

my $stage1 = 0;
my $stage2 = 0;

my @f = map { [split//] } read_file(\*STDIN, chomp => 1);

my $g = Graph::Directed->new;

my $wy = scalar(@f);
my $wx = scalar(@{$f[0]});
my $maxy = $wy - 1;
my $maxx = $wx - 1;

my ($sx,$sy,$ex,$ey);

for my $y (0..$maxy)
{
    for my $x (0..$maxx)
    {
        my $e = $f[$y]->[$x];
        if ($e eq 'S')
        {
            $f[$y]->[$x] = 'a';
            $sx = $x;
            $sy = $y;
        }
        if ($e eq 'E')
        {
            $f[$y]->[$x] = 'z';
            $ex = $x;
            $ey = $y;
        }
    }
}

for my $y (0..$maxy)
{
    for my $x (0..$maxx)
    {

        my $e = $f[$y]->[$x];

        for my $dy (-1..1)
        {
            for my $dx (-1..1)
            {
                    next if abs($dx) + abs($dy) == 0;
                    next if abs($dx) + abs($dy) != 1;
                    my $xdx = $x + $dx;
                    my $ydy = $y + $dy;
                    next if $xdx < 0 || $xdx > $maxx;
                    next if $ydy < 0 || $ydy > $maxy;

                    my $v = ord($e) - ord('a');
                    my $ed = $f[$ydy]->[$xdx];
                    my $vd = ord($ed) - ord('a');
                    my $dif = $vd - $v;

                    next if $dif > 1;

#                    print "$x,$y ($e: $v) -> $xdx,$ydy ($ed: $vd) => $dif\n";
                    # $g->add_weighted_edge($x.$;.$y, "$xdx$;$ydy", $dif);
                    $g->add_edge("$x,$y","$xdx,$ydy");

            }
        }

    }
}
print "vertices: ".scalar($g->vertices)."\n";
print "edges: ".scalar($g->edges)."\n";

my @p1 = $g->SP_Dijkstra("$sx,$sy", "$ex,$ey");
$stage1 = scalar(@p1) - 1;
printf "Stage 1: %s\n", $stage1;

$stage2 = $stage1;
for my $x (0..$maxx)
{
    for my $y (0..$maxy)
    {
        my $e = $f[$y]->[$x];
        next unless $e eq 'a';

        my @p1 = $g->SP_Dijkstra("$x,$y", "$ex,$ey");
        my $l = scalar(@p1) - 1;

print("$x,$y $l $stage2\n");

        next if $l == -1;
        $stage2 = $l if $l < $stage2;
    }
}
printf "Stage 2: %s\n", $stage2;

