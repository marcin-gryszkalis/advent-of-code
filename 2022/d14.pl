#!/usr/bin/perl
use warnings;
use strict;
use File::Slurp;
use Data::Dumper;
use List::Util qw/min max first sum product all any uniq head tail reduce/;
$; = ",";

my @f = read_file(\*STDIN, chomp => 1);

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
            my ($x1,$x2) = sort($x,$px);
            my ($y1,$y2) = sort($y,$py);
            $minx = min($x1,$minx); $maxx = max($x2,$maxx);
            $miny = min($y1,$miny); $maxy = max($y2,$maxy);

            if ($px == $x)
            {
                for my $ty ($y1..$y2) { $m->{$x,$ty} = '#' }
            }
            else
            {
                for my $tx ($x1..$x2) { $m->{$tx,$y} = '#' }
            }
        }

        ($px,$py) = ($x,$y);
    }
}

L: while (1)
{
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

        if ($y == $maxy) # bypassed last rock
        {
            last L;
        }
    }
}

printf "Stage 1: %s\n", scalar grep { /o/ } values %$m;

K: while (1)
{
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

            last K if $y == 0; # stuck at the start
            next K;
        }
    }
}

printf "Stage 2: %s\n", scalar grep { /o/ } values %$m;

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
