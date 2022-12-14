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

my $sx = 500;
my $sy = 0;

my $m;

my $minx = 10000;
my $miny = 10000;
my $maxx = 0;
my $maxy = 0;
for (@f)
{
    my @a = split/ -> /;
    my $px = -1;
    my $py = -1;
    for my $e (@a)
    {
        my ($x,$y) = split(/,/, $e);
        if ($px != -1)
        {
            my $x1 = min($x, $px);
            my $x2 = max($x, $px);
            my $y1 = min($y, $py);
            my $y2 = max($y, $py);

#print "$x1 - $x2, $y1 - $y2\n";
            $maxx = $x2 if $x2 > $maxx;
            $maxy = $y2 if $y2 > $maxy;
            $minx = $x1 if $x1 < $minx;
            $miny = $y1 if $y1 < $miny;

            if ($px == $x)
            {
                for my $ty ($y1..$y2)
                {
                    $m->{$x,$ty} = '#';
                }
            }
            else
            {
                for my $tx ($x1..$x2)
                {
                    $m->{$tx,$y} = '#';
                }

            }
        }

        $px = $x;
        $py = $y;


    }
}

# print Dumper $m;
# print "$minx - $maxx; $miny - $maxy\n";


my $i = 0;
L: while (1)
{
    $i++;

    my $x = $sx;
    my $y = $sy;

    while (1)
    {
        if ($y == $maxy + 1)
        {
            $m->{$x,$y} = 'o';
            next L;
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

            if ($y == 0)
            {
                last L;
            }
            next L;
        }

        # if ($y > $maxy)
        # {
                $i--;
        #     last L;
        # }

        # for my $y (0..$maxy)
        # {
        #     for my $x ($minx..$maxx)
        #     {
        #         my $v = '.';
        #         if (exists $m->{$x,$y})
        #         {
        #             $v = $m->{$x,$y};
        #         }
        #         print $v;
        #     }
        #     print "\n";
        # }

    }

}
printf "Stage 1: %s\n", $i;
printf "Stage 2: %s\n", $stage2;