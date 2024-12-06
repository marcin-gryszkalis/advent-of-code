#!/usr/bin/perl
use warnings;
use strict;
use feature qw/state signatures say multidimensional/;
use File::Slurp;
use Data::Dumper;
use List::Util qw/min max first sum sum0 product all any uniq head tail reduce pairs pairmap pairgrep pairfirst pairkeys pairvalues zip mesh/;
use List::MoreUtils qw/firstidx frequency mode pairwise slide minmax minmaxstr/;
# use Algorithm::Combinatorics qw/combinations permutations variations/;
use POSIX qw/ceil floor/;
use Clone qw/clone/;
$; = ',';

my @dirs = ( [0,-1], [1,0], [0, 1], [-1, 0] );

my @f = read_file(\*STDIN, chomp => 1);

my $stage1 = 0;
my $stage2 = 0;

my $x = 0;
my $y = 0;
my $m = {};
my $startx;
my $starty;
for (@f)
{
    $x = 0;
    for my $v (split//)
    {
        $m->{$x,$y} = $v;
        if ($v eq '^')
        {
            ($startx, $starty)  = ($x, $y);
        }
        $x++;
    }
    $y++;
}

my ($h, $w) = ($y, length($f[0]));
my ($maxy, $maxx) = ($h - 1, $w - 1);

($x, $y) = ($startx, $starty);
my $dir = 0;
my $t = clone $m;
my $xed;
while (1)
{
    $t->{$x,$y} = 'X';
    $xed->{$x,$y} = 1;

    my ($nx, $ny) = ($x + $dirs[$dir]->[0], $y + $dirs[$dir]->[1]);
    last if $nx < 0 || $nx > $maxx || $ny < 0 || $ny > $maxy;
    if ($t->{$nx,$ny} eq '#')
    {
        $dir = ($dir + 1) % 4;
        redo;
    }
    ($x, $y) = ($nx, $ny);

}

$stage1 = grep { $_ eq 'X' } values %$t;


for my $ox (0..$maxx)
{
    Y: for my $oy (0..$maxy)
    {
        next unless exists $xed->{$ox,$oy};

        next if $m->{$ox,$oy} eq '^' || $m->{$ox,$oy} eq '#';
        my $t = clone $m;
        $t->{$ox,$oy} = '#';

        ($x, $y) = ($startx, $starty);
        my $dir = 0;
        while (1)
        {
            if ($t->{$x,$y} =~ /$dir/) # loop
            {
                $stage2++;
                last;
            }

            $t->{$x,$y} .= $dir;

            my ($nx, $ny) = ($x + $dirs[$dir]->[0], $y + $dirs[$dir]->[1]);

            last if $nx < 0 || $nx > $maxx || $ny < 0 || $ny > $maxy;

            if ($t->{$nx,$ny} eq '#')
            {
                $dir = ($dir + 1) % 4;
                redo;
            }
            ($x, $y) = ($nx, $ny);
        }
    }
}



say "Stage 1: ", $stage1;
say "Stage 2: ", $stage2;