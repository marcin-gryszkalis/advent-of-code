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

my @f = read_file(\*STDIN, chomp => 1);

my $stage1 = 0;
my $stage2 = 0;

my $x = 0;
my $y = 0;
my $t;
my $startx;
my $starty;
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
my ($maxy, $maxx) = ($h - 1, $w - 1);

my $found;
for $y (0..$maxy)
{
    for $x (0..$maxx)
    {
        next if $t->{$x,$y};

        $stage2 += travel($x,$y);
        $stage1 += scalar keys %$found;
        $found = undef;
    }
}

sub travel($x,$y)
{
    return 0 if $x < 0 || $x > $maxx || $y < 0 || $y > $maxy;
    return $found->{$x,$y} = 1 if $t->{$x,$y} == 9;

    my $s = 0;
    $s += travel($x - 1, $y) if $x > 0 && $t->{$x-1,$y} - $t->{$x,$y} == 1;
    $s += travel($x + 1, $y) if $x < $maxx && $t->{$x+1,$y} - $t->{$x,$y} == 1;
    $s += travel($x, $y - 1) if $y > 0 && $t->{$x,$y-1} - $t->{$x,$y} == 1;
    $s += travel($x, $y + 1) if $y < $maxy && $t->{$x,$y+1} - $t->{$x,$y} == 1;

    return $s;
}

say "Stage 1: ", $stage1;
say "Stage 2: ", $stage2;
