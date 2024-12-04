#!/usr/bin/perl
use warnings;
use strict;
use feature qw/state signatures say multidimensional/;
use File::Slurp;
use Data::Dumper;
use List::Util qw/min max first sum sum0 product all any uniq head tail reduce pairs pairmap pairkeys pairvalues zip mesh/;
use List::MoreUtils qw/firstidx frequency mode pairwise slide minmax minmaxstr/;
use POSIX qw/ceil floor/;
use Clone qw/clone/;
$; = ',';

my @xmas = qw/X M A S/;
my @mas = qw/M A S/;

my @f = read_file(\*STDIN, chomp => 1);

my $stage1 = 0;
my $stage2 = 0;

my $x = 0;
my $y = 0;
my $t;

for (@f)
{
    $x = 0;
    for my $v (split//)
    {
        $t->{$x,$y} = $v;
        $x++;
    }
    $y++;
}

my $h = $y;
my $w = length($f[0]);
my $maxy = $h - 1;
my $maxx = $w - 1;

my $cnt;
for my $sx (0..$maxx)
{
    for my $sy (0..$maxy)
    {
        for my $dx (-1..1)
        {
            DY: for my $dy (-1..1)
            {
                $x = $sx;
                $y = $sy;
                for my $l (0..$#xmas)
                {
                    next DY if $x < 0 || $x > $maxx || $y < 0 || $y > $maxy;
                    next DY if $t->{$x,$y} ne $xmas[$l];
                    $x += $dx;
                    $y += $dy;
                }
                $stage1++;
            }
        }

        for my $dx (qw/-1 1/)
        {
            DY: for my $dy (qw/-1 1/)
            {
                $x = $sx;
                $y = $sy;
                for my $l (0..$#mas)
                {
                    next DY if $x < 0 || $x > $maxx || $y < 0 || $y > $maxy;
                    next DY if $t->{$x,$y} ne $mas[$l];
                    $x += $dx;
                    $y += $dy;
                }

                $stage2++ if exists $cnt->{$sx+$dx, $sy+$dy};
                $cnt->{$sx+$dx, $sy+$dy} = 1;
            }
        }
    }
}

say "Stage 1: ", $stage1;
say "Stage 2: ", $stage2;