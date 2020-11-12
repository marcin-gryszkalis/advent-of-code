#!/usr/bin/perl
use warnings;
use strict;
use Data::Dumper;
use List::Util qw/min max/;
use File::Slurp;
use Algorithm::Combinatorics qw(combinations permutations);
use Digest::MD5 qw(md5 md5_hex md5_base64);

my $GSN = 5235;
my $N = 300;

my $grid;
for my $x (1..$N)
{
    for my $y (1..$N)
    {
        my $rid = $x + 10;
        my $power = $rid * $y;
        $power += $GSN;
        $power *= $rid;
        if ($power =~ m/\d*(\d)\d\d$/) { $power = $1 } else { $power = 0 }
        $power -= 5;

        $grid->[$x]->[$y] = $power;
    }
}

my $sums;
for my $stage (1..2)
{
    my $best = 0;
    my $bestx = 0;
    my $besty = 0;
    my $bestr = 1;

    my @range = $stage == 1 ? (3..3) : (4..300);
    for my $r (@range)
    {
        for my $x (1..$N-$r+1)
        {
            for my $y (1..$N-$r+1)
            {
                my $s = 0;
                # cache of square sums to be used on next level
                if (exists $sums->{$r-1}->{$x}->{$y})
                {
                    $s = $sums->{$r-1}->{$x}->{$y};
                    for my $dx (0..$r-1)
                    {
                        $s += $grid->[$x+$dx]->[$y+$r-1];
                    }
                    for my $dy (0..$r-2) # -2 for not to calc corner twice
                    {
                        $s += $grid->[$x+$r-1]->[$y+$dy];
                    }
                }
                else
                {
                    die "$r,$x,$y" if $stage == 2;
                    for my $dx (0..$r-1)
                    {
                        for my $dy (0..$r-1)
                        {
                            $s += $grid->[$x+$dx]->[$y+$dy];
                        }
                    }
                }

                $sums->{$r}->{$x}->{$y} = $s;
                if ($s > $best)
                {
                    $best = $s;
                    $bestx = $x;
                    $besty = $y;
                    $bestr = $r;
                    printf "best %d: %d at %d,%d\n", $bestr, $best, $bestx, $besty;
                }
            }
        }
     }

    printf("stage $stage: %d at %d,%d,%d\n", $best, $bestx, $besty, $bestr);
}