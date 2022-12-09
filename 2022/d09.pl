#!/usr/bin/perl
#use v5.36;
use warnings;
use strict;
use File::Slurp;
use Data::Dumper;
use List::Util qw/min max first sum product all any uniq head tail reduce/;
use Algorithm::Combinatorics qw(combinations permutations variations);
use Clone qw/clone/;

my @f = read_file(\*STDIN, chomp => 1);

my $stage1 = 0;
my $stage2 = 0;

my $hx = 100;
my $hy = 100;
my $tx = $hx;
my $ty = $hy;
my $v;

my $dx;
my $dy;
for (@f)
{
    die unless /(.) (\d+)/;
    my ($d,$c) = ($1,$2);

    print "> $d $c\n";
    if ($d eq 'R') { $hx += $c; }
    if ($d eq 'L') { $hx -= $c; }
    if ($d eq 'U') { $hy -= $c; }
    if ($d eq 'D') { $hy += $c; }


    while (1)
    {
        $v->{$tx,$ty} = 1;

        my $dist = (abs($ty-$hy) + abs($tx-$hx));

        print "$hx,$hy - $tx,$ty = $dist\n";

        if ($tx == $hx || $ty == $hy)  # same row or col
        {
            last if $dist < 2;

            if ($tx == $hx)
            {
                $dy = ($hy <=> $ty);
                $ty += $dy;
            }
            else
            {
                $dx = ($hx <=> $tx);
                $tx += $dx;
            }
        }
        else # diagonal
        {
            last if $dist < 3;
                $dy = ($hy <=> $ty); # $hy - $ty;
                $ty += $dy;

                $dx = ($hx <=> $tx);
                $tx += $dx;

            # if (abs($ty-$hy) == 1)
            # {
            # }
            # else
            # {
            #     $dx = ($hx <=> $tx); # $hx - $tx;
            #     $tx += $dx;

            #     $dy = ($hy <=> $ty);
            #     $ty += $dy;
            # }
        }

    }
}

$stage1 = scalar keys %$v;
printf "Stage 1: %s\n", $stage1;
printf "Stage 2: %s\n", $stage2;