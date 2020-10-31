#!/usr/bin/perl
use strict;
use warnings;
use Data::Dumper;
use List::Util qw/min max/;
use File::Slurp;

$_ = <>;
my @a = split/,\s*/;

my $x = 0;
my $y = 0;

my $d = 0; # N = 0
my @dx = qw/0 1 0 -1/; # clockwise
my @dy = qw/1 0 -1 0/;

my $h;
$h->{$x}->{$y} = 1;

my $dist2 = 0;
for my $k (@a)
{

    my ($turn,$len) = split//,$k,2;
    if ($turn eq 'R')
    {
        $d = ($d+1) % 4;
    }
    else # L
    {
        $d = ($d+3) % 4;
    }

    my $nx = $x + $dx[$d]*$len;
    my $ny = $y + $dy[$d]*$len;

    while (1) # step by step
    {
        $x += $dx[$d];
        $y += $dy[$d];

        if ($dist2 == 0)
        {
            if (exists $h->{$x}->{$y})
            {
                $dist2 = abs($x) + abs($y);
            }

            $h->{$x}->{$y} = 1;
        }

        last if $x == $nx && $y == $ny;
    }
    # print "$turn:$len -- d=$d -- ($x,$y) --- $dist2\n";
}

my $dist = abs($x) + abs($y);

printf "stage 1: %d\n", $dist;
printf "stage 2: %d\n", $dist2;
