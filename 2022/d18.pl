#!/usr/bin/perl
use warnings;
use strict;
use File::Slurp;
use Data::Dumper;
use List::Util qw/min max first sum product all any uniq head tail reduce/;
use Algorithm::Combinatorics qw(combinations permutations variations);
use Clone qw/clone/;
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
    my @e = split/,/;
    $m->{$e[0],$e[1],$e[2]} = 1;

#print Dumper $m;
    $stage1 += 6;
    $stage1 -= 2 if exists $m->{$e[0]+1,$e[1],$e[2]};
    $stage1 -= 2 if exists $m->{$e[0]-1,$e[1],$e[2]};
    $stage1 -= 2 if exists $m->{$e[0],$e[1]-1,$e[2]};
    $stage1 -= 2 if exists $m->{$e[0],$e[1]+1,$e[2]};
    $stage1 -= 2 if exists $m->{$e[0],$e[1],$e[2]-1};
    $stage1 -= 2 if exists $m->{$e[0],$e[1],$e[2]+1};

    $minx = min($minx, $e[0]);
    $miny = min($miny, $e[1]);
    $minz = min($minz, $e[2]);

    $maxx = max($maxx, $e[0]);
    $maxy = max($maxy, $e[1]);
    $maxz = max($maxz, $e[2]);
}

$stage2 = $stage1;

my $q;
for my $x ($minx..$maxx)
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

my $i = 0;
while (1)
{
    printf "$i %d\n", scalar(%$q);
    last if scalar(%$q) == 0;

    my $k = (keys(%$q))[0];
    delete $q->{$k};
    $m->{$k} = 2;

    my @e = split/,/,$k;

    for my $x (-1..1)
    {
        for my $y (-1..1)
        {
            for my $z (-1..1)
            {
                next if abs($x) + abs($y) + abs($z) != 1;
                next if
                    $e[0] + $x > $maxx ||
                    $e[0] + $x < $minx ||
                    $e[1] + $y > $maxy ||
                    $e[1] + $y < $miny ||
                    $e[2] + $z > $maxz ||
                    $e[2] + $z < $minz;
                next if exists $m->{$e[0]+$x,$e[1]+$y,$e[2]+$z};
                next if exists $q->{$e[0]+$x,$e[1]+$y,$e[2]+$z};
printf "xxx $minx,$maxx %d,%d,%d\n",$e[0]+$x,$e[1]+$y,$e[2]+$z;
                $q->{$e[0]+$x,$e[1]+$y,$e[2]+$z} = 1;
            }
        }
    }

    $i++;
}

my $pockets = 0;
for my $x ($minx+1..$maxx-1)
{
    for my $y ($miny+1..$maxy-1)
    {
        for my $z ($minz+1..$maxz-1)
        {
            next if exists $m->{$x,$y,$z};
print "$pockets $x,$y,$z\n";
            $pockets++;

            for my $dx (-1..1)
            {
                for my $dy (-1..1)
                {
                    for my $dz (-1..1)
                    {
                next if abs($dx) + abs($dy) + abs($dz) != 1;
#printf "check %d,%d,%d = %d\n", $x+$dx,$y+$dy,$z+$dz, abs($x + $dx) + abs($y + $dy) + abs($z + $dz);
                        if (exists $m->{$x+$dx,$y+$dy,$z+$dz} && $m->{$x+$dx,$y+$dy,$z+$dz} == 1)
                        {
                            $stage2--;
                        }

                    }
                }
            }

        }
    }
}
print Dumper $m;
printf "Stage 1: %s\n", $stage1;
printf "Stage 2: %s\n", $stage2;
# 2506
