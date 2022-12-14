#!/usr/bin/perl
use warnings;
use strict;
use File::Slurp;
use Data::Dumper;
use List::Util qw/min max first sum product all any uniq head tail reduce/;
use Algorithm::Combinatorics qw(combinations permutations variations);
use Clone qw/clone/;
$; = ",";

my @f = read_file(\*STDIN, chomp => 1);

my $stage1 = 0;
my $stage2 = 0;

my ($sx,$sy) = (500,0);

my $m;

my ($minx,$maxx) = (10000,0);
my ($miny,$maxy) = (10000,0);

for (@f)
{
    my ($px,$py) = (-1,-1);
    for (split/ -> /)
    {
        my ($x,$y) = split/,/;
        if ($px != -1)
        {
            my $x1 = min($x, $px); $minx = $x1 if $x1 < $minx;
            my $y1 = min($y, $py); $miny = $y1 if $y1 < $miny;
            my $x2 = max($x, $px); $maxx = $x2 if $x2 > $maxx;
            my $y2 = max($y, $py); $maxy = $y2 if $y2 > $maxy;

            if ($px == $x)
            {
                for my $ty ($y1..$y2) { $m->{$x,$ty} = '#' }
            }
            else
            {
                for my $tx ($x1..$x2) { $m->{$tx,$y} = '#' }
            }
        }

        $px = $x;
        $py = $y;
    }
}

L: while (1)
{
    $stage1++;
    my ($x,$y) = ($sx,$sy);

    while (1)
    {
        if (!exists $m->{$x,$y+1})
        {
            $y++;
        }
        elsif (!exists $m->{$x-1,$y+1})
        {
            $x--;
            $y++;
        }
        elsif (!exists $m->{$x+1,$y+1})
        {
            $x++;
            $y++;
        }
        else # blocked
        {
            $m->{$x,$y} = 'o';
            next L;
        }

        if ($y == $maxy)
        {
            $stage1--;
            last L;
        }
    }
}

$stage2 = $stage1;
K: while (1)
{
    $stage2++;
    my ($x,$y) = ($sx,$sy);

    while (1)
    {
        if ($y == $maxy + 1)
        {
            $m->{$x,$y} = 'o';
            next K;
        }

        if (!exists $m->{$x,$y+1})
        {
            $y++;
        }
        elsif (!exists $m->{$x-1,$y+1})
        {
            $x--;
            $y++;
        }
        elsif (!exists $m->{$x+1,$y+1})
        {
            $x++;
            $y++;
        }
        else # blocked
        {
            $m->{$x,$y} = 'o';

            last K if $y == 0;
            next K;
        }
    }
}

printf "Stage 1: %s\n", $stage1;
printf "Stage 2: %s\n", $stage2;

# $minx -= 10;
# $maxx += 10;
# $maxy ++;
# for my $y (0..$maxy)
# {
#     for my $x ($minx..$maxx)
#     {
#         print exists $m->{$x,$y} ? $m->{$x,$y} : '.';
#     }
#     print "\n";
# }
