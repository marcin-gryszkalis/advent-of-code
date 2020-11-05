#!/usr/bin/perl
use warnings;
use strict;
use Data::Dumper;
use List::Util qw/min max/;
use List::MoreUtils qw(uniq);
use File::Slurp;
use Algorithm::Combinatorics qw(combinations permutations);

my $h;

my @f = read_file(\*STDIN);
my $i = 0;
for (@f)
{
    # position=<-53868, -10684> velocity=< 5,  1>
    die $_ unless /position=<\s*(-?\d+),\s*(-?\d+)>\s+velocity=<\s*(-?\d+),\s*(-?\d+)>/;
    $h->[$i]->{x} = $1;
    $h->[$i]->{y} = $2;
    $h->[$i]->{vx} = $3;
    $h->[$i]->{vy} = $4;

    $i++;
}

my $marginx = 100; # shoot
my $marginy = 40;

my $prevsd = 0;
my $sd = 0;

my $second = 0;
while (1)
{
    my $minx = 1000000;
    my $miny = 1000000;
    my $maxx = -$minx;
    my $maxy = -$miny;

    for my $p (@$h)
    {
        $p->{x} += $p->{vx};
        $p->{y} += $p->{vy};
        $minx = $p->{x} if $p->{x} < $minx;
        $miny = $p->{y} if $p->{y} < $miny;
        $maxx = $p->{x} if $p->{x} > $maxx;
        $maxy = $p->{y} if $p->{y} > $maxy;
    }

    $sd = $maxx-$minx + $maxy-$miny;
    if ($prevsd > 0 && $sd > $prevsd)
    {
        print "stage 2: $second\n";
        exit;
    }
    $prevsd = $sd;

    if ($maxx - $minx < $marginx && $maxy - $miny < $marginy)
    {
        my $screen = {};
        for my $p (@$h)
        {
            $screen->{$p->{x}}->{$p->{y}} = 1;
        }

        for my $y ($miny-1..$maxy+1)
        {
            for my $x ($minx-1..$maxx+1)
            {
                print((exists $screen->{$x}->{$y}) ? '#' : '.');
            }
            print "\n";
        }

        sleep(1);
        print "\n";
    }

    $second++;
}