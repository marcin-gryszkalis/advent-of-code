#!/usr/bin/perl
use warnings;
use strict;
use feature qw/state signatures say multidimensional/;
use File::Slurp;
use Data::Dumper;
use List::Util qw/min max first sum sum0 product all any uniq head tail reduce pairs zip mesh/;
use List::MoreUtils qw/firstidx frequency mode slide minmax/;
use POSIX qw/ceil floor/;
use Algorithm::Combinatorics qw/combinations permutations variations/;
use Clone qw/clone/;
$; = ',';

use Array::Heap::PriorityQueue::Numeric;
my $q = Array::Heap::PriorityQueue::Numeric->new();

my @f = read_file(\*STDIN, chomp => 1);

my $stage1 = 0;
my $stage2 = 0;

my @dirs = ([-1,0],[0,1],[1,0],[0,-1]);

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

my ($h, $w) = ($y, length($f[0]));
my ($maxx, $maxy) = ($w - 1, $h - 1);

$x = 0;
$y = 0;

sub proceed($stage)
{
    $q->add([0,0,-100,0,0], 0); # x, y, direction index, how long straight in this dir, distance (same as key)

    my $d;
    my $result = 1_000_000_000;

    while ($a = $q->get())
    {
        my ($x,$y,$dir,$straight,$distance) = @$a;

        next if exists $d->{$x,$y,$dir,$straight};

        $d->{$x,$y,$dir,$straight} = $distance;

        if ($x == $maxx && $y == $maxy)
        {
            next if $stage == 2 && $straight < 4; # it needs to move a minimum of four blocks in that direction before it can turn (**or even before it can stop at the end**)
            $result = min($result,$distance)
        }

        for my $ndir (0..3)
        {
            next if abs($dir - $ndir) == 2; # opposite directions

            my $nstraight = $ndir != $dir ? 1 : $straight + 1;

            if ($stage == 1)
            {
                next if $nstraight > 3;
            }
            else
            {
                next if $nstraight > 10;
                next if $ndir != $dir && $straight > 0 && $straight < 4;
            }

            my $nx = $x + $dirs[$ndir]->[0];
            my $ny = $y + $dirs[$ndir]->[1];
            next if $nx < 0 || $nx > $maxx;
            next if $ny < 0 || $ny > $maxy;

            my $ndistance = $distance + $t->{$nx,$ny};

            $q->add([$nx,$ny,$ndir,$nstraight,$ndistance], $ndistance);
        }

    }

    printf "Stage $stage: %s\n", $result;
}

proceed($_) for (1..2)
# 1080 too low
# 1152 too hi
# 1033 invalid
