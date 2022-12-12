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
        my $k = $f[$y][$x];

        if ($k eq 'S')
        {
            $k = 'a';
            $sx = $x; $sy = $y;
        }

        if ($k eq 'E')
        {
            $k = 'z';
            $ex = $x; $ey = $y;
        }

        $f[$y][$x] = ord($k) - ord('a');
    }
}

for my $y (0..$maxy)
{
    for my $x (0..$maxx)
    {
        my $e = $f[$y][$x];

        for my $dy (-1..1)
        {
            for my $dx (-1..1)
            {
                next if abs($dx) + abs($dy) != 1;
                my $xdx = $x + $dx;
                my $ydy = $y + $dy;
                next if $xdx < 0 || $xdx > $maxx;
                next if $ydy < 0 || $ydy > $maxy;

                next unless $f[$ydy][$xdx] - $e >= -1; # reverse: >= -1, forward: <= 1

                $g->add_edge("$x,$y", "$xdx,$ydy");
            }
        }

    }
}

# searching in reverse (from end to start) is faster for given input (lot of unused 'a's)
my @p1 = $g->SP_Dijkstra("$ex,$ey", "$sx,$sy");
$stage1 = scalar(@p1) - 1;
printf "Stage 1: %s\n", $stage1;

$stage2 = $stage1;
for my $x (0..$maxx)
{
    for my $y (0..$maxy)
    {
        my $k = $f[$y][$x];
        next unless $k == 0; # 'a'

        my @p1 = $g->SP_Dijkstra("$ex,$ey", "$x,$y");
        my $l = scalar(@p1) - 1;

        next if $l == -1; # unreachable
        $stage2 = $l if $l < $stage2;
    }
}
printf "Stage 2: %s\n", $stage2;

