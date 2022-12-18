#!/usr/bin/perl
use warnings;
use strict;
use File::Slurp;
use Data::Dumper;
use List::Util qw/min max first sum product all any uniq head tail reduce/;
$; = ',';

my @f = read_file(\*STDIN, chomp => 1);

my $stage1 = 0;
my $stage2 = 0;

my ($minx,$maxx) = (100,-1);
my ($miny,$maxy) = (100,-1);
my ($minz,$maxz) = (100,-1);

my $m;
for (@f)
{
    my ($x,$y,$z) = split/,/;
    $m->{$x,$y,$z} = 1;

    $stage1 += 6;
    for my $dx (-1..1)
    {
        for my $dy (-1..1)
        {
            for my $dz (-1..1)
            {
                next if abs($dx) + abs($dy) + abs($dz) != 1;
                $stage1 -= 2 if exists $m->{$x+$dx,$y+$dy,$z+$dz};
            }
        }
    }

    $minx = min($minx, $x);
    $miny = min($miny, $y);
    $minz = min($minz, $z);

    $maxx = max($maxx, $x);
    $maxy = max($maxy, $y);
    $maxz = max($maxz, $z);
}

# bfs reachable space inside
my $q;
for my $x ($minx..$maxx) # scan the surface for holes
{
    for my $y ($miny..$maxy)
    {
        for my $z ($minz..$maxz)
        {
            next unless
                $x == $minx ||
                $x == $maxx ||
                $y == $miny ||
                $y == $maxy ||
                $z == $minz ||
                $z == $maxz;

            next if exists $m->{$x,$y,$z};

            $q->{$x,$y,$z} = 1;
        }
    }
}

while (scalar(%$q))
{
    my $k = (keys(%$q))[0];
    delete $q->{$k};

    $m->{$k} = 2;

    my ($x,$y,$z) = split/,/,$k; # because $; = ','

    for my $dx (-1..1)
    {
        for my $dy (-1..1)
        {
            for my $dz (-1..1)
            {
                next if abs($dx) + abs($dy) + abs($dz) != 1;
                next if
                    $x + $dx > $maxx ||
                    $x + $dx < $minx ||
                    $y + $dy > $maxy ||
                    $y + $dy < $miny ||
                    $z + $dz > $maxz ||
                    $z + $dz < $minz;

                next if exists $m->{$x+$dx,$y+$dy,$z+$dz};

                $q->{$x+$dx,$y+$dy,$z+$dz} = 1;
            }
        }
    }
}

$stage2 = $stage1;

for my $x ($minx+1..$maxx-1)
{
    for my $y ($miny+1..$maxy-1)
    {
        for my $z ($minz+1..$maxz-1)
        {
            next if exists $m->{$x,$y,$z};

            for my $dx (-1..1)
            {
                for my $dy (-1..1)
                {
                    for my $dz (-1..1)
                    {
                        next if abs($dx) + abs($dy) + abs($dz) != 1;
                        $stage2-- if exists $m->{$x+$dx,$y+$dy,$z+$dz} && $m->{$x+$dx,$y+$dy,$z+$dz} == 1;
                    }
                }
            }

        }
    }
}

printf "Stage 1: %s\n", $stage1;
printf "Stage 2: %s\n", $stage2;
