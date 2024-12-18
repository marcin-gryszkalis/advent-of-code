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

my $stage1 = 0;
my $stage2 = 0;

my @op = (
    [1,0],  # >
    [0,1],  # v
    [-1,0], # <
    [0,-1], # ^
);

my @f = read_file(\*STDIN, chomp => 1);

my ($startx, $starty) = (0, 0);
my ($maxy, $maxx) = (0, 0);
for (@f)
{
    my ($x,$y) = /(\d+)/g;
    $maxx = max($maxx, $x);
    $maxy = max($maxy, $y);
}

my ($endx, $endy) = ($maxy, $maxx);
my $limit = $maxx == 6 ? 12 : 1024; # hardocded from description

my $t;
my $i = 0;
while (1)
{
    $_ = shift @f;
    my ($x,$y) = /(\d+)/g;
    $t->{$x,$y} = 1;
    last if $i++ == $limit;
}

my $fall = -1;
while (1)
{
    my $bestcost = 1_000_000_000;

    my @q = ();
    my $vis = undef;
    push(@q, [$startx, $starty, 0]);
    Q: while (my $e = shift @q)
    {
        my ($x, $y, $cost) = @$e;
        next if $vis->{$x,$y};

        $vis->{$x,$y} = 1;
        if ($x == $endx && $y == $endy)
        {
#            say "$fall $cost";
            $bestcost = $cost;
            $stage1 = $bestcost unless $stage1;
            last;
        }

        for my $i (0..3)
        {
            my $d = $op[$i];
            my ($nx,$ny) = ($x + $d->[0], $y + $d->[1]);
            next if $nx > $maxx || $nx < 0 || $ny > $maxy || $ny < 0;
            next if $vis->{$nx,$ny};
            next if $t->{$nx,$ny};
            push(@q, [$nx, $ny, $cost + 1]);
        }
    }

    if ($bestcost == 1_000_000_000)
    {
        $stage2 = $fall;
        last;
    }

    $fall = shift @f;
    last unless defined $fall;
    my ($x,$y) = $fall =~/(\d+)/g;
    $t->{$x,$y} = "#";
}

say "Stage 1: ", $stage1;
say "Stage 2: ", $stage2;

