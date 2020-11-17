#!/usr/bin/perl
use warnings;
use strict;
use Data::Dumper;
use List::Util qw/min max first sum product/;
use List::MoreUtils qw(uniq);
use File::Slurp;
use Algorithm::Combinatorics qw(combinations permutations);

# from d10:
sub knot($)
{
    my $input = shift;

    my $L = 256;
    my $add = "17,31,73,47,23";

    my $ROUNDS = 64;

    my @a = map { ord($_) } split//, $input;
    push(@a, split(/,/, $add));

    my @x = (0..$L-1);

    my $i = 0;
    my $skip = 0;
    my $shft = 0;
    for my $r (0..$ROUNDS-1)
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
    for my $block (0..15)
    {
        my $q = 0;
        for my $e (0..15)
        {
            $q ^= $x[$block * 16 + $e];
        }
        $res .= sprintf("%02x", $q);
    }

    return $res;

}


my $prefix = "ffayrhll";

my @disk;

for my $i (0..127)
{
    my $s = "$prefix-$i";
    my $h = knot($s);
    my $hb = '';

    for my $d (split//, $h)
    {
        $hb .= sprintf("%04b", hex($d));
    }

    $hb =~ tr/01/.#/;
    printf "$hb\n";

    my @row = split//, $hb;
    push(@disk, \@row);
}

my $total = 0;
sub cleanup
{
    $total++;

    my ($r, $c) = @_;
    $disk[$r][$c] = 'x';

    cleanup($r-1, $c) if $r > 0 && $disk[$r-1][$c] eq '#';
    cleanup($r+1, $c) if $r < 127 && $disk[$r+1][$c] eq '#';
    cleanup($r, $c-1) if $c > 0 && $disk[$r][$c-1] eq '#';
    cleanup($r, $c+1) if $c < 127 && $disk[$r][$c+1] eq '#';
}


my $regions = 0;
for my $r (0..127)
{
    for my $c (0..127)
    {
        if ($disk[$r][$c] eq '#')
        {
            cleanup($r, $c);
            $regions++;
        }
    }
}

printf "stage 1: %d\n", $total;
printf "stage 2: %d\n", $regions;

