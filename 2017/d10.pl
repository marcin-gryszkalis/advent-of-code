#!/usr/bin/perl
use warnings;
use strict;
use Data::Dumper;
use List::Util qw/min max first sum product/;
use List::MoreUtils qw(uniq);
use File::Slurp;
use Algorithm::Combinatorics qw(combinations permutations);

my $L = 256;
my $input = "94,84,0,79,2,27,81,1,123,93,218,23,103,255,254,243";
my $add = "17,31,73,47,23";

my @ROUNDS = qw/1 64/;

for my $stage (1..2)
{
    my @a;
    if ($stage == 1)
    {
        @a = split/,/, $input;
    }
    else
    {
        @a = map { ord($_) } split//, $input;
        push(@a, split(/,/, $add));
    }

    my @x = (0..$L-1);

    my $i = 0;
    my $skip = 0;
    my $shft = 0;
    for my $r (0..$ROUNDS[$stage-1]-1)
    {
        for my $len (@a)
        {
            @x = (reverse(@x[0..$len-1]), @x[$len..$L-1]); # assume: current-pos == 0

            $i = ($i + $len + $skip) % $L;

            if ($i > 0)
            {
                @x = (@x[$i..$L-1], @x[0..$i-1]);
                $shft = ($shft + $L -$i) % $L;
                $i = 0;
            }

            $skip++;
        }
    }

    @x = (@x[$shft..$L-1], @x[0..$shft-1]);

    my $res;
    if ($stage == 1)
    {
        $res = $x[0] * $x[1];
    }
    else
    {
        for my $block (0..15)
        {
            my $q = 0;
            for my $e (0..15)
            {
                $q ^= $x[$block * 16 + $e];
            }
            $res .= sprintf("%02x", $q);
        }
    }
    printf "stage $stage: %s\n", $res;

}