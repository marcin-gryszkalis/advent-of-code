#!/usr/bin/perl
use warnings;
use strict;
use feature qw/state signatures say multidimensional/;
use File::Slurp;
use Data::Dumper;
use List::Util qw/min max first sum sum0 product all any uniq head tail reduce pairs pairkeys pairvalues zip mesh/;
use List::MoreUtils qw/firstidx frequency mode pairwise slide minmax minmaxstr/;
use Algorithm::Combinatorics qw/combinations permutations variations variations_with_repetition/;
use POSIX qw/ceil floor/;
use Clone qw/clone/;
$; = ',';

my @f = read_file(\*STDIN, chomp => 1);

my $stage1 = 0;
my $stage2 = 0;

my $startx = 0;
my $starty = 0;

my $x = 0;
my $y = 0;

my $t;

for (@f)
{
    $x = 0;
    for my $v (split//)
    {
        $t->{$x,$y} = $v;
        ($startx, $starty) = ($x,$y) if $v eq 'S';
        $x++;
    }
    $y++;
}

my $h = $y;
my $w = length($f[0]);
my $maxy = $h - 1;
my $maxx = $w - 1;

my $mem;
sub tach($x, $y)
{
    return 1 if $y == $maxy;
    return $mem->{$x,$y} if exists $mem->{$x,$y};

    if ($t->{$x,$y+1} eq '.')
    {
        return $mem->{$x, $y} = tach($x, $y+1)
    }
    else
    {
        $stage1++;
        return $mem->{$x, $y} = tach($x-1, $y+1) + tach($x+1, $y+1);
    }
}

$stage2 = tach($startx, $starty);

say "Stage 1: $stage1";
say "Stage 2: $stage2";